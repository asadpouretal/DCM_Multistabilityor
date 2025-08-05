function estimate_dcm_for_erp_unparallel(data_struct, fs, main_folder, response_type, DT)
    % This function estimates Dynamic Causal Modeling (DCM) for ERP data.
    % It assumes there are only lateral connections among two sources per trial.
    % Inputs:
    %   data_struct - Structure containing input and output data matrices
    %   fs - Sampling frequency in Hz
    %   main_folder - Base directory for saving the results
    %   response_type - Subfolder name under main_folder where results will be saved
    %   DT - Decimation factor for downsampling the data

    % Define the directory to save the results
    save_folder = fullfile(main_folder, response_type);
    
    % Remove the subfolder if it exists and recreate it
    if exist(save_folder, 'dir')
        rmdir(save_folder, 's');  % Remove directory and its contents recursively
    end
    mkdir(save_folder);  % Create a new clean directory
    
    % Number of trials (assuming same number of trials for all sources)
    num_trials = size(data_struct.input1, 1);
    
    % Time vector in milliseconds
    time_vector = linspace(0, (size(data_struct.output1_EEG, 2) - 1) / fs * 1000, size(data_struct.output1_EEG, 2));
    
    % Loop over each trial to set up and estimate DCM
    for i = 1:num_trials
        % Extract data for this trial
        current_input = [data_struct.input1(i, :); data_struct.input2(i, :)];
        current_output = [data_struct.output1_EEG(i, :); data_struct.output2_EEG(i, :)];

        % Set up for two types of DCM models
        models = {'lateral', 'forward-backward'};
        for m = 1:length(models)
            % Basic setup for the DCM structure
            DCM = [];
            DCM.name = sprintf('DCM_Trial_%d_%s', i, models{m}); % Naming each DCM model
            DCM.Lpos = []; % Assume no source locations are provided
            DCM.Sname = {'Source1', 'Source2'};
            
            % DCM data options
            DCM.options.DATA = 0; % Indicate no data files are to be used
            
            % Time window and bins for modelling
            DCM.options.Tdcm = [0 (size(current_output, 2) - 1) / fs * 1000]; % Convert samples to time window in ms
            T1 = DCM.options.Tdcm(1);
            T2 = DCM.options.Tdcm(2);
            [~, T1_index] = min(abs(time_vector - T1));
            [~, T2_index] = min(abs(time_vector - T2));
            
            It = (T1_index:DT:T2_index)';
            Ns = length(It); % Number of samples
            h = 1;
            if h == 0
                X0 = sparse(Ns,1);
            else
                X0 = spm_dctmtx(Ns,h);
            end
            % Update DCM.xY fields
            DCM.xY.modality = 'LFP';  % Set modality, change to 'EEG' if using EEG data
            DCM.xY.Time = time_vector;  % Time [ms] data
            DCM.xY.pst = time_vector(It);  % Down-sampled PST
            DCM.xY.dt = DT/fs;  % Sampling interval in seconds
            DCM.xY.y = {current_output'};  % Trial-specific response
            DCM.xY.It = It;  % Indices of time bins
            DCM.xY.Ic = [1 2];  % Indices of good channels
            DCM.xY.name = {'Source1', 'Source2'};  % Names of channels
            DCM.xY.scale = 1;  % Scale factor (assumed to be 1 unless specified)
            DCM.xY.coor2D = [];  % 2D coordinates for plotting (if applicable)
            DCM.xY.X0 = X0;  % DCT confounds
            DCM.xY.R = speye(Ns) - X0*X0';  % Residual forming matrix
            DCM.xY.Hz = [];  % Frequency bins for Wavelet transform (if applicable)
    
            % Design (input) specification
            DCM.xU.u = current_input';
            DCM.xU.name = {'Input1', 'Input2'};        
            
            % Set connectivity based on model type
            switch models{m}
                case 'lateral'
                    DCM.A{1} = zeros(2,2); % No forward connections
                    DCM.A{2} = zeros(2,2); % No backward connections
                    DCM.A{3} = [0 1; 1 0]; % Only lateral connections
                case 'forward-backward'
                    DCM.A{1} = [0 1; 0 0]; % Forward connection from 1 to 2
                    DCM.A{2} = [0 0; 1 0]; % Backward connection from 2 to 1
                    DCM.A{3} = zeros(2,2); % No lateral connections
            end

            DCM.B = {}; % Assuming no modulatory influences
            DCM.C = eye(2); % Direct inputs to both sources
            
            % Model options
            DCM.options.trials = 1;
            DCM.options.D = 1;
            DCM.options.h = h;
            DCM.options.analysis = 'ERP';
            DCM.options.model = 'ERP';
            DCM.options.spatial = 'LFP';
            DCM.options.onset = 0; % Stimulus onset in ms, adjust as necessary
            DCM.options.dur = 128; % Example duration
            DCM.options.CVA = 0;
            DCM.options.Nmax = 128; % Maximum number of iterations
    
            DCM.M.dipfit.type     = DCM.options.spatial;
            DCM.M.dipfit.location = 0;
            DCM.M.dipfit.symmetry = 0;        
            DCM.M.dipfit.modality = DCM.options.spatial;
            DCM.M.dipfit.Ns       = length(DCM.Sname);
            DCM.M.dipfit.Nc       = length(DCM.xY.Ic);
    
    
                    
            % Estimate the DCM parameters
            DCM = spm_dcm_erp(DCM);
            
            % Save the model in the specified directory
            filename = fullfile(save_folder, sprintf('DCM_Model_Trial_%d_%s.mat', i, models{m}));
            save(filename, 'DCM');
        end
    end

    fprintf('DCM analysis completed for %d trials and saved in %s.\n', num_trials, save_folder);
end
