%% Initializing
clc; close all;
restoredefaultpath;   % Reset the path to the default state
clear;

% Setup paths based on operating system
switch filesep
    case '\'
        disp('MATLAB is running on Windows.');
        main_folder = 'D:\Data\DCM validation\period_doubling_csd';
        spm_path = 'C:\Users\aaa210\OneDrive - University of Sussex\Toolboxes\spm12';
        addpath(spm_path);
        spm;  % Start SPM
        close all;  % Close SPM GUI
        spm('defaults', 'EEG');
    case '/'
        disp('MATLAB is running on Linux.');
        main_folder = '/mnt/scratch2/users/DCM validation/period doubling';
        jobStorageLocation = '/users/ParallelJobStorage/';
        spm_path = 'spm12';        
        addpath(spm_path);
        spm;  % Start SPM
        close all;  % Close SPM GUI
        spm('defaults', 'EEG');
        % Setup parallel computing environment
        poolobj = gcp('nocreate');  % Do not create a new pool if it already exists
        if ~isempty(poolobj)
            delete(poolobj);  % Delete existing parallel pool to restart
        end

        % Automatically retrieve the number of workers from the default cluster
        numWorkers = feature('numcores');  % Automatically extract the number of workers
        disp(['Number of workers available: ', num2str(numWorkers)]);

        existingProfiles = parallel.clusterProfiles();
        profileName = existingProfiles{1};
%         numWorkers = 100;  % Adjust this number based on your hardware capabilities
        matlabRoot = matlabroot;     
        modifyCustomParallelProfile(profileName, numWorkers, matlabRoot, jobStorageLocation);
        parpool(profileName, numWorkers);
end

%% Find the path of the current code and copy files
current_code_path = fileparts(mfilename('fullpath'));  % Get the directory of the running code
source_folder = fullfile(current_code_path, 'DCM FSM');  % Source folder containing files to copy
destination_folder = fullfile(spm_path, 'toolbox', 'dcm_meeg');  % Destination folder

% Check if source folder exists
if exist(source_folder, 'dir')
    disp(['Copying files from ', source_folder, ' to ', destination_folder]);

    % Ensure the destination directory exists or create it
    if ~exist(destination_folder, 'dir')
        mkdir(destination_folder);
    end

    % Copy all files from source folder to destination folder
    copyfile(source_folder, destination_folder);
else
    disp('Source folder does not exist. Skipping file copying step.');
end

%% Simulation parameters and data generation
fs= 10000; %Sampling frequency
n = 200; %Number of trials
FC=[0 0 0 0 0 0];

ts=0 : 1/fs : 1.5;
tf=ts(end);
t0=ts(1);
X1=0.018*rand(n,length(ts)) / 0.1; %input 1
X2=0.012*rand(n,length(ts)) / 0.1; %input 2

% File location for saving data
data_filename = fullfile(main_folder, 'simulated_data_period_doubling.mat');

% Generate data only if it does not exist
if ~exist(data_filename, 'file')
    disp('Generating new data...');
        for i = 1:n
            options = odeset('RelTol', 1e-4, 'AbsTol', ones(1, 6) * 1e-4, 'MaxStep', abs(t0 - tf) / 10);
            [t, yg_temp] = ode45(@(t, yg) NET_period_doubling(t, yg, ts, X1(i, :), ts, X2(i, :)), ts, FC, options);
            yg(i, :, :) = yg_temp;
            
            % Extract yg dimensions
            yg_i = squeeze(yg(i, :, :));
        
            LFP(i, :) = -(yg_i(:, 2)); % LFP definition for column 1
            
            LFP1(i, :) = -(yg_i(:, 5));% LFP definition for column 2
        end

        period_doubling_trials = struct('input1', X1(:,:), ...
                           'input2', X2(:,:), ...
                           'output1_e1', yg(:,:,1), ...
                           'output1_e2', yg(:,:,2), ...
                           'output1_i1', yg(:,:,3), ...
                           'output2_e1', yg(:,:,4), ...
                           'output2_e2', yg(:,:,5), ...
                           'output2_i1', yg(:,:,6), ...
                           'output1_LFP', LFP(:,:), ...
                           'output2_LFP', LFP1(:,:));
    
    % Create directory if it does not exist
    if ~exist(main_folder, 'dir')
        mkdir(main_folder);
    end
    
    % Save all generated data
    save(data_filename, 'period_doubling_trials', '-v7.3');
else
    disp('Data file already exists. Loading data for further processing...');
end



% Load and proceed with DCM estimation
response_type = 'period_doubling_trials';
data = load(data_filename, response_type);  % Load correct trials for DCM analysis
down_sample = 1;



% Access the variable dynamically from the structure
variable_to_pass = data.(response_type);

% plotLogSTFT(variable_to_pass.output1_LFP(1, :)', fs);

% Call the function with the dynamically accessed variable
estimate_dcm_for_csd(variable_to_pass, fs, main_folder, response_type, down_sample);

% Additional analysis can be uncommented and used as required
% plot_analysis(a_values, acc, avg_decision_rts, avg_error_rts);
