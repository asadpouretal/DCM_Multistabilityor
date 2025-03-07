%% Initializing
clc; close all;
restoredefaultpath;   % Reset the path to the default state
clear;

% Setup paths based on operating system
switch filesep
    case '\'
        disp('MATLAB is running on Windows.');
        main_folder = 'C:\Data\DCM validation\two column EEG DCM';
        spm_path = 'C:\Toolbox\spm12';
        addpath(spm_path);
        spm;  % Start SPM
        close all;  % Close SPM GUI
        spm('defaults', 'EEG');
    case '/'
        disp('MATLAB is running on Linux.');
        main_folder = '/mnt/scratch2/users/DCM validation/two column EEG DCM';
        jobStorageLocation = '/users/ParallelJobStorage/';
        spm_path = '/users/spm12';        
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

% Simulation parameters
num_trials=4000;
fs=1000;         %Sampling frequency
decision_boundary=0.15; 
a_values = (0.1:0.025:0.2);   %Different evidence quality = ((a_values-0.1)/(a_values+0.1))

% File location for saving data
data_filename = fullfile(main_folder, 'simulated_data.mat');

% Generate data only if it does not exist
if ~exist(data_filename, 'file')
    disp('Generating new data...');
        for i=1:length(a_values)
        
        [acc(i),decision_reaction_times,error_reaction_times,decision_trial_indices,error_trial_indices,non_decision_trial_indices,...
         o1_e1,o1_e2,o1_i1,o2_e1,o2_e2,o2_i1,input_1,input_2,avg_decision_rts(i),avg_error_rts(i),output1_LFP,output2_LFP]=fsm3(num_trials,fs,decision_boundary,a_values(i));


        non_decision_trial_indices1{i}=non_decision_trial_indices;
        correct_trials{i} = struct('input1', input_1(decision_trial_indices,:), ...     %Input to column1
                                   'input2', input_2(decision_trial_indices,:), ...     %Input to column2
                                   'output1_e1', (o1_e1(decision_trial_indices,:)), ... %Output of neuron e1 in column1
                                   'output1_e2', (o1_e2(decision_trial_indices,:)), ... %Output of neuron e2 in column1
                                   'output1_i1', o1_i1(decision_trial_indices,:), ...   %Output of neuron i1 in column1
                                   'output2_e1', (o2_e1(decision_trial_indices,:)), ... %Output of neuron e1 in column2
                                   'output2_e2', (o2_e2(decision_trial_indices,:)), ... %Output of neuron e2 in column2
                                   'output2_i1', o2_i1(decision_trial_indices,:), ...   %Output of neuron i1 in column2
                                   'output1_LFP', output1_LFP(decision_trial_indices,:), ... %Output of LFP in column1
                                   'output2_LFP', output2_LFP(decision_trial_indices,:), ... %Output of LFP in column2
                                   'reaction_times', decision_reaction_times);               %Decision time
        
        error_trials{i} = struct('input1', input_1(error_trial_indices,:), ...  %Similar to correct trial
                                   'input2', input_2(error_trial_indices,:), ...
                                   'output1_e1', o1_e1(error_trial_indices,:), ...
                                   'output1_e2', o1_e2(error_trial_indices,:), ...
                                   'output1_i1', o1_i1(error_trial_indices,:), ...
                                   'output2_e1', o2_e1(error_trial_indices,:), ...
                                   'output2_e2', o2_e2(error_trial_indices,:), ...
                                   'output2_i1', o2_i1(error_trial_indices,:), ...
                                   'output1_LFP', output1_LFP(error_trial_indices,:), ...
                                   'output2_LFP', output2_LFP(error_trial_indices,:), ...
                                   'reaction_times', error_reaction_times);
        
        non_decision_trials{i} = struct('input1', input_1(non_decision_trial_indices,:), ...  %Similar to correct trial
                                   'input2', input_2(non_decision_trial_indices,:), ...
                                   'output1_e1', o1_e1(non_decision_trial_indices,:), ...
                                   'output1_e2', o1_e2(non_decision_trial_indices,:), ...
                                   'output1_i1', o1_i1(non_decision_trial_indices,:), ...
                                   'output2_e1', o2_e1(non_decision_trial_indices,:), ...
                                   'output2_e2', o2_e2(non_decision_trial_indices,:), ...
                                   'output2_i1', o2_i1(non_decision_trial_indices,:), ...
                                   'output1_LFP', output1_LFP(non_decision_trial_indices,:), ...
                                   'output2_LFP', output2_LFP(non_decision_trial_indices,:));
        end
    
    % Create directory if it does not exist
    if ~exist(main_folder, 'dir')
        mkdir(main_folder);
    end
    
    % Save all generated data
    save(data_filename, 'correct_trials', 'error_trials', 'non_decision_trials', '-v7.3');
else
    disp('Data file already exists. Loading data for further processing...');
end

% Load and proceed with DCM estimation
response_type = 'correct_trials';
data = load(data_filename, response_type);  % Load correct trials for DCM analysis
down_sample = 1;

% Access the variable dynamically from the structure
variable_to_pass = data.(response_type);

evidence_quality_number = 1;    % evidence quality number

% Call the function with the dynamically accessed variable
estimate_dcm_for_erp_fc(variable_to_pass{evidence_quality_number}, fs, main_folder, response_type, a_values(evidence_quality_number), down_sample); % estimate_dcm_for_erp(variable_to_pass{evidence_quality_number}, fs, main_folder, response_type, a_values(evidence_quality_number), down_sample);

% Additional analysis can be uncommented and used as required
% plot_analysis(a_values, acc, avg_decision_rts, avg_error_rts);
