%% Initializing
clc; close all;
restoredefaultpath;   % Reset the path to the default state
clear;
trial_type = {'correct_trials', 'error_trials'};

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
        main_folder = '/mnt/scratch2/users/aasadpour/DCM validation/period doubling';
        jobStorageLocation = '/users/aasadpour/ParallelJobStorage/';
        spm_path = '/users/aasadpour/spm12';        
        addpath(spm_path);
        spm;  % Start SPM
        close all;  % Close SPM GUI
        spm('defaults', 'EEG');
        % Setup parallel computing environment
        % poolobj = gcp('nocreate');  % Do not create a new pool if it already exists
        % if ~isempty(poolobj)
        %     delete(poolobj);  % Delete existing parallel pool to restart
        % end
        % existingProfiles = parallel.clusterProfiles();
        % profileName = existingProfiles{1};
        % numWorkers = length(trial_type);  % Adjust this number based on your hardware capabilities
        % matlabRoot = matlabroot;     
        % modifyCustomParallelProfile(profileName, numWorkers, matlabRoot, jobStorageLocation);
        % parpool(profileName, numWorkers);
end


a_values = (0.1:0.025:0.2);   %Different evidence quality = ((a_values-0.1)/(a_values+0.1))

try
    dataFolder = fullfile(main_folder);
    modelNames = {'Lat', 'F-B', 'FC'};
    outputFolder = fullfile(main_folder, 'BMS');
    
    % Call the function to perform DCM BMS batch processing
    performDCMBMSBatch(dataFolder, modelNames, outputFolder);
    performDCMPEBAnalysis(dataFolder, modelNames, outputFolder);
    performPEBWithinSubjectModels(dataFolder, modelNames, outputFolder);
catch ME
    % Display error message and continue with the next iteration
    fprintf('Error processing %s: \n', ME.message);
end
