function estimate_dcm_for_erp_fc(data_struct, fs, main_folder, response_type, evidence_quality, DT)
    % This function estimates Dynamic Causal Modeling (DCM) for ERP data.
    % It assumes there are only lateral connections among two sources per trial.
    % Inputs:
    %   data_struct - Structure containing input and output data matrices
    %   fs - Sampling frequency in Hz
    %   main_folder - Base directory for saving the results
    %   response_type - Subfolder name under main_folder where results will be saved
    %   DT - Decimation factor for downsampling the data

    % Define the directory to save the results
    save_folder = fullfile(main_folder, 'FC', response_type, num2str(evidence_quality));
    if exist(save_folder, 'dir')
        rmdir(save_folder, 's');
    end
    mkdir(save_folder);
    max_num_trials = 200;
    % Time vector for modeling
    num_trials = size(data_struct.input1, 1);
    if num_trials > max_num_trials
        num_trials = max_num_trials;
    end
    time_vector = linspace(0, (size(data_struct.output1_LFP, 2) - 1) / fs * 1000, size(data_struct.output1_LFP, 2));

    % Conditional loop setup based on the operating system
    if filesep == '/'
        disp('Running on Linux: Using parallel processing...');
        parfor i = 1:num_trials
            process_trial(i, data_struct, time_vector, DT, fs, main_folder, save_folder);
        end
    else
        disp('Running on Windows: Using sequential processing...');
        for i = 1:num_trials
            process_trial(i, data_struct, time_vector, DT, fs, main_folder, save_folder);
        end
    end

    fprintf('DCM analysis completed for %d trials and saved in %s.\n', num_trials, save_folder);
end

function process_trial(i, data_struct, time_vector, DT, fs, main_folder, save_folder)
    % This function processes individual trials for DCM setup and estimation.
    current_input = [data_struct.input1(i, :); data_struct.input2(i, :)];
    current_output = [data_struct.output1_LFP(i, :); data_struct.output2_LFP(i, :)];

    models = {'Lat','FB','FC'};
    for m = 1:length(models)
        % Initialize and configure DCM
        DCM = setup_dcm(current_input, current_output, time_vector, DT, fs, models{m});

        % Save the model in the specified directory
        filename = fullfile(save_folder, sprintf('DCM_Model_Trial_%d_%s.mat', i, models{m}));
        save(filename, 'DCM');
    end
end
function DCM = setup_dcm(current_input, current_output, time_vector, DT, fs, model_type)
    % Set up DCM model with specified connectivity patterns.
    DCM = [];
    DCM.name = sprintf('DCM_Model_%s', model_type);
    
    % Initialize source names
    DCM.Sname = {'Source1', 'Source2'};  % Define the names of the sources

    DCM.options.DATA = 0;
    DCM.options.Tdcm = [0 (size(current_output, 2) - 1) / fs * 1000];
    [T1_index, T2_index] = find_time_indices(DCM.options.Tdcm, time_vector);
    It = (T1_index:DT:T2_index)';
    Ns = length(It);
    DCM.xY = setup_xY(current_output, It, time_vector, DT, fs, Ns);
    DCM.xU = setup_xU(current_input);
    DCM = define_connectivity(DCM, model_type);

    % Additional DCM configurations
    DCM.options.trials = 1;
    DCM.options.D = 1;
    DCM.options.h = 1;
    DCM.options.analysis = 'ERP';
    DCM.options.model = 'ERP';
    DCM.options.spatial = 'LFP';  % This should be set to either 'LFP', 'EEG', 'MEG', depending on the data
    DCM.options.onset = 0;
    DCM.options.dur = 128;
    DCM.options.CVA = 0;
    DCM.options.Nmax = 128;

    % Configure dipfit settings
    DCM.M.dipfit.type = DCM.options.spatial;
    DCM.M.dipfit.location = 0;  % This usually needs specification based on the data model
    DCM.M.dipfit.symmetry = 0;
    DCM.M.dipfit.modality = DCM.options.spatial;
    DCM.M.dipfit.Ns = length(DCM.Sname);  % Number of sources
    DCM.M.dipfit.Nc = length(DCM.xY.Ic);  % Number of channels

    % Estimate the DCM parameters
    DCM = spm_dcm_erp(DCM);
end



function [T1_index, T2_index] = find_time_indices(Tdcm, time_vector)
    % Find the index range based on the time window specified for DCM.
    T1 = Tdcm(1);
    T2 = Tdcm(2);
    [~, T1_index] = min(abs(time_vector - T1));
    [~, T2_index] = min(abs(time_vector - T2));
end

function xY = setup_xY(current_output, It, time_vector, DT, fs, Ns)
    % Setup xY fields for DCM
    xY.modality = 'LFP';  % or 'EEG' based on your data
    xY.Time = time_vector;
    xY.pst = time_vector(It);
    xY.dt = DT/fs;
    xY.y = {current_output'};
    xY.It = It;
    xY.Ic = [1 2];
    xY.name = {'Source1', 'Source2'};
    xY.scale = 1;
    xY.X0 = spm_dctmtx(Ns,1);       % for DCM.options.h = 1
    xY.R = speye(Ns) - xY.X0*xY.X0';
end

function xU = setup_xU(current_input)
    % Setup input specification for DCM
    xU.u = current_input';
    xU.name = {'Input1', 'Input2'};
end

function DCM = define_connectivity(DCM, model_type)
    % Define connectivity matrices based on the model type
    switch model_type
        case 'Lat'
            DCM.A{1} = zeros(2,2);
            DCM.A{2} = zeros(2,2);
            DCM.A{3} = [0 1; 1 0];  % Lateral connections only
        case 'FB'
            DCM.A{1} = [0 1; 0 0];  % Forward from Source1 to Source2
            DCM.A{2} = [0 0; 1 0];  % Backward from Source2 to Source1
            DCM.A{3} = zeros(2,2);  % No lateral connections
        case 'FC'
            DCM.A{1} = [0 1; 0 0];  % Forward from Source1 to Source2
            DCM.A{2} = [0 0; 1 0];  % Backward from Source2 to Source1
            DCM.A{3} = [0 1; 1 0];  % Lateral connections
    end
    DCM.B = {};
    DCM.C = eye(2);
end
