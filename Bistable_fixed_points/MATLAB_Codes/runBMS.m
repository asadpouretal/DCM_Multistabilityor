%% Initializing
clc; close all;
restoredefaultpath;   % Reset the path to the default state
clear;

% Setup paths based on operating system
switch filesep
    case '\'
        disp('MATLAB is running on Windows.');
        main_folder = 'U:\Data\DCM validation\two column EEG DCM';
        spm_path = 'C:\Toolbox\spm12';
        addpath(spm_path);
        spm;  % Start SPM
        close all;  % Close SPM GUI
        spm('defaults', 'EEG');
    case '/'
        disp('MATLAB is running on Linux.');
        main_folder = '/mnt/scratch2/users/aasadpour/DCM validation/two column EEG DCM';
        jobStorageLocation = '/users/aasadpour/ParallelJobStorage/';
        spm_path = '/users/aasadpour/spm12';        
        addpath(spm_path);
        spm;  % Start SPM
        close all;  % Close SPM GUI
        spm('defaults', 'EEG');
        % Setup parallel computing environment
        poolobj = gcp('nocreate');  % Do not create a new pool if it already exists
        if ~isempty(poolobj)
            delete(poolobj);  % Delete existing parallel pool to restart
        end
        existingProfiles = parallel.clusterProfiles();
        profileName = existingProfiles{1};
        numWorkers = 4;  % Adjust this number based on your hardware capabilities
        matlabRoot = matlabroot;     
        modifyCustomParallelProfile(profileName, numWorkers, matlabRoot, jobStorageLocation);
        parpool(profileName, numWorkers);
end

trial_type = {'correct_trials', 'error_trials'};
a_values = (0.1:0.025:0.2);   %Different evidence quality = ((a_values-0.1)/(a_values+0.1))

for i = 1 : length(trial_type)
    parfor evidence_quality_number = 1 : 4
        try
            dataFolder = fullfile(main_folder, trial_type{i}, num2str(a_values(evidence_quality_number)));
            modelNames = {'lateral', 'forward_backward'};
            outputFolder = fullfile(main_folder, 'BMS', trial_type{i}, num2str(a_values(evidence_quality_number)));
            
            % Call the function to perform DCM BMS batch processing
            performDCMBMSBatch(dataFolder, modelNames, outputFolder);
        catch ME
            % Display error message and continue with the next iteration
            fprintf('Error processing %s with a_value %f: %s\n', trial_type{i}, a_values(evidence_quality_number), ME.message);
        end
    end
end