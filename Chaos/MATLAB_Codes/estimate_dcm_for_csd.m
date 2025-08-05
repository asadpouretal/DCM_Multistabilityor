function estimate_dcm_for_csd(data_struct, fs, main_folder, response_type, DT, f, f1)
    % This function estimates Dynamic Causal Modeling (DCM) for CSD data.
    % It assumes there are only lateral connections among two sources per trial.
    % Inputs:
    %   data_struct - Structure containing input and output data matrices
    %   fs - Sampling frequency in Hz
    %   main_folder - Base directory for saving the results
    %   response_type - Subfolder name under main_folder where results will be saved
    %   DT - Decimation factor for downsampling the data

    % Define the directory to save the results
    save_folder = fullfile(main_folder, response_type);
    if ~exist(save_folder, 'dir')
        mkdir(save_folder);
    end
    
    max_num_trials = 400;
    % Time vector for modeling
    num_trials = size(data_struct.input1, 1);
    if num_trials > max_num_trials
        num_trials = max_num_trials;
    end
    time_vector = linspace(0, (size(data_struct.output1_LFP, 2) - 1) / fs * 1000, size(data_struct.output1_LFP, 2));

    % Compute CSD for all trials first
    fprintf('Computing cross-spectral densities for %d trials...\n', num_trials);
    
    % Initialize CSD structure
    DCM_template = [];
    DCM_template.options.Tdcm = [0 (size(data_struct.output1_LFP, 2) - 1) / fs * 1000];
    [T1_index, T2_index] = find_time_indices(DCM_template.options.Tdcm, time_vector);
    It = (T1_index:DT:T2_index)';
    
    % Set frequency range
    fmin = min(f, f1);
    fmax = max(f, f1);
    buffer_low = 5;
    buffer_high = fmax * 0.2;
    Fdcm_start = max(1, floor(fmin - buffer_low));
    Fdcm_end = min(fs/2, ceil(fmax + buffer_high));
    % Automatically determine natural frequency resolution
    T = (size(data_struct.output1_LFP, 2) - 1) / fs;  % trial duration in seconds
    df = 1 / T;
    
    % Define frequency vector using finer resolution (e.g., 0.67 Hz)
    Nf = round((Fdcm_end - Fdcm_start) / df);  % number of frequency bins
    freqs = linspace(Fdcm_start, Fdcm_end, Nf);
    
    % Compute multitaper cross-spectral densities using pmtm and cpsd
    CSD_all = cell(num_trials, 1);
    nTapers = 5;  % multitaper smoothing
    win = hanning(length(It));  % window length matches downsampled trial
    
    for i = 1:num_trials
        % Extract trial data: [time × channels]
        Y = [data_struct.output1_LFP(i, It)' data_struct.output2_LFP(i, It)'];
        nCh = size(Y, 2);
        nFreq = length(freqs);
        csd = zeros(nFreq, nCh, nCh);
    
        for ch1 = 1:nCh
            for ch2 = ch1:nCh
                [Pxy, f_vec] = cpsd(Y(:, ch1), Y(:, ch2), win, [], Nf, fs / DT);
                % Interpolate to target freqs if needed
                Pxy_interp = interp1(f_vec, Pxy, freqs, 'linear', 'extrap');
                csd(:, ch1, ch2) = Pxy_interp;
                csd(:, ch2, ch1) = conj(Pxy_interp);
            end
        end
    
        % Save per trial
        CSD_all{i} = csd;
    end


    % Conditional loop setup based on the operating system
    if filesep == '/'
        disp('Running on Linux: Using parallel processing...');
        trial_indices = 1:num_trials;
        
        parfor idx = 1:length(trial_indices)
            i = trial_indices(idx);
            process_trial_csd(i, data_struct, time_vector, DT, fs, save_folder, f, f1, CSD_all{i}, freqs, It);
        end
    else
        disp('Running on Windows: Using sequential processing...');
        for i = 1:num_trials
            process_trial_csd(i, data_struct, time_vector, DT, fs, save_folder, f, f1, CSD_all{i}, freqs, It);
        end
    end

    fprintf('DCM analysis completed for %d trials and saved in %s.\n', num_trials, save_folder);
end

function process_trial_csd(i, data_struct, time_vector, DT, fs, save_folder, f, f1, CSD_trial, Hz, It)
    % This function processes individual trials for DCM setup and estimation.
    current_input = [data_struct.input1(i, :); data_struct.input2(i, :)];
    
    models = {'Lat', 'F-B', 'FC'};
    for m = 1:length(models)
        % Initialize and configure DCM
        DCM = setup_dcm_csd(current_input, time_vector, DT, fs, models{m}, f, f1, CSD_trial, Hz, It);

        % Save the model in the specified directory
        filename = fullfile(save_folder, sprintf('DCM_Model_Trial_%d_%s.mat', i, models{m}));
        save(filename, 'DCM', '-v7.3');
    end
end

function DCM = setup_dcm_csd(current_input, time_vector, DT, fs, model_type, f, f1, CSD_trial, Hz, It)
    % Set up DCM model with specified connectivity patterns for CSD analysis.
    DCM = [];
    DCM.name = sprintf('DCM_Model_%s', model_type);
    
    % Initialize source names
    DCM.Sname = {'Source1', 'Source2'};
    
    % Options
    DCM.options.DATA = 0;
    DCM.options.Tdcm = [time_vector(It(1)) time_vector(It(end))];
    
    % Frequency window
    fmin = min(f, f1);
    fmax = max(f, f1);
    buffer_low = 5;
    buffer_high = 100;
    Fdcm_start = max(1, floor(fmin - buffer_low));
    Fdcm_end = min(fs/2, ceil(fmax + buffer_high));
    DCM.options.Fdcm = [Fdcm_start, Fdcm_end];

    % Setup xY for CSD
    DCM.xY = setup_xY_csd(CSD_trial, It, time_vector, DT, fs, Hz);
    
    % Setup input
    DCM.xU = setup_xU(current_input);
    
    % Define connectivity
    DCM = define_connectivity(DCM, model_type);
    
    % Additional DCM configurations
    DCM.options.trials = 1;
    DCM.options.D = 1;
    DCM.options.h = 1;
    DCM.options.analysis = 'CSD';
    DCM.options.model = 'ERP';  % Changed from 'ERP' to 'CSD'
    DCM.options.spatial = 'LFP';
    DCM.options.onset = 0;
    DCM.options.dur = 16;  % Reduced from 128 for CSD
    DCM.options.Nmax = 128;
    DCM.options.Nmodes = 8;

    % Configure dipfit settings
    DCM.M.dipfit.type = DCM.options.spatial;
    DCM.M.dipfit.location = 0;
    DCM.M.dipfit.symmetry = 0;
    DCM.M.dipfit.modality = DCM.options.spatial;
    DCM.M.dipfit.Ns = length(DCM.Sname);
    DCM.M.dipfit.Nc = length(DCM.xY.Ic);

    % Estimate the DCM parameters
    DCM = spm_dcm_csd(DCM);
end

function xY = setup_xY_csd(CSD_trial, It, time_vector, DT, fs, Hz)
    % Setup xY fields for DCM-CSD
    xY.modality = 'LFP';
    xY.Time = time_vector;
    xY.pst = time_vector(It);
    xY.dt = DT/fs;
    xY.Hz = Hz;
    xY.y = CSD_trial;  % This should be the cross-spectral density
    xY.It = It;
    xY.Ic = [1 2];
    xY.name = {'Source1', 'Source2'};
    xY.scale = 1;
    
    % Setup Q matrix (sensor covariance components)
    % For CSD, Q should be automatically computed by spm_dcm_csd_Q
    % but we need to ensure the data is in the right format
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
        case 'F-B'
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

function [T1_index, T2_index] = find_time_indices(Tdcm, time_vector)
    % Find the index range based on the time window specified for DCM.
    T1 = Tdcm(1);
    T2 = Tdcm(2);
    [~, T1_index] = min(abs(time_vector - T1));
    [~, T2_index] = min(abs(time_vector - T2));
end