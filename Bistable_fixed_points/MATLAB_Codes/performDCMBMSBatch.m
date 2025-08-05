function performDCMBMSBatch(dataFolder, modelNames, outputFolder)
    % performDCMBMSBatch - Performs Bayesian Model Selection (BMS) and potentially Bayesian Model Averaging (BMA)
    % using SPM's batch system for specified DCM models in a given trial organization, ignoring incomplete trials.
    %
    % Syntax: performDCMBMSBatch(dataFolder, modelNames, outputFolder)
    %
    % Inputs:
    %    dataFolder - Path to the folder containing the DCM files organized by trial.
    %    modelNames - Cell array of model names included in the DCM filenames.
    %    outputFolder - Output directory for BMS results.
    %
    % Example:
    %    performDCMBMSBatch('U:/Data/DCM validation/two column EEG DCM/non_decision_trials', ...
    %                       {'lateral', 'forward_backward'}, ...
    %                       'U:/Data/DCM validation/two column EEG DCM/non_decision_trials');

    spm('defaults', 'EEG');
    spm_jobman('initcfg');

    if exist(outputFolder, 'dir')
        rmdir(outputFolder, 's');  % Remove directory and its contents recursively
    end
    mkdir(outputFolder);  % Create a new clean directory    

    % List all DCM files recursively
    files = dir(fullfile(dataFolder, '**', '*.mat'));
    
    % Initialize variables for batch processing
    sess_dcm = {};
    nSessions = 0;
    trialData = struct();  % Initialize trialData as a struct

    % Find unique trials based on file naming convention within subfolders
    for i = 1:length(files)
        [~, name, ~] = fileparts(files(i).name);
        trialMatch = regexp(name, 'DCM_Model_Trial_(\d+)_', 'tokens');
        if ~isempty(trialMatch)
            trial = trialMatch{1}{1};
            subfolder = files(i).folder;
            keySource = fullfile(subfolder, trial); 
            keyHash = ['k' DataHash(keySource)]; % Prepend a letter to ensure valid field name

            if ~isfield(trialData, keyHash)
                trialData.(keyHash) = struct('trial', trial, 'subfolder', subfolder, 'files', {cell(1, length(modelNames))}, 'complete', true);
            end
            for j = 1:length(modelNames)
                expectedFileName = sprintf('DCM_Model_Trial_%s_%s.mat', trial, modelNames{j});
                if strcmp(files(i).name, expectedFileName)
                    trialData.(keyHash).files{j} = fullfile(subfolder, files(i).name);
                end
            end
            % Check completeness of the trial data
            if any(cellfun(@isempty, trialData.(keyHash).files))
                trialData.(keyHash).complete = false;
            else
                trialData.(keyHash).complete = true;
            end
        end
    end

    % Collect complete trials
    trialKeys = fieldnames(trialData);
    for i = 1:length(trialKeys)
        if trialData.(trialKeys{i}).complete
            nSessions = nSessions + 1;
            sess_dcm{1}(nSessions).dcmmat = trialData.(trialKeys{i}).files';
        end
    end

    % Setup batch only if there are complete sessions
    if nSessions > 0
        matlabbatch{1}.spm.dcm.bms.inference.dir = {outputFolder};
        matlabbatch{1}.spm.dcm.bms.inference.sess_dcm = sess_dcm;
        matlabbatch{1}.spm.dcm.bms.inference.model_sp = {''};
        matlabbatch{1}.spm.dcm.bms.inference.load_f = {''};
        matlabbatch{1}.spm.dcm.bms.inference.method = 'RFX';

        % Setup family configuration dynamically based on model names
        for m = 1:length(modelNames)
            matlabbatch{1}.spm.dcm.bms.inference.family_level.family(m).family_name = modelNames{m};
            matlabbatch{1}.spm.dcm.bms.inference.family_level.family(m).family_models = m;
        end

        matlabbatch{1}.spm.dcm.bms.inference.bma.bma_yes.bma_part = 1;
        matlabbatch{1}.spm.dcm.bms.inference.verify_id = 1;

        % Run the batch
        spm_jobman('run', matlabbatch);
    else
        disp('No complete trials were found. Batch processing was not started.');
    end
end

function hash = DataHash(data)
    % DataHash - Compute MD5 hash of the given data
    % This is a simple implementation to generate a hash of the input data
    engine = java.security.MessageDigest.getInstance('MD5');
    engine.update(uint8(data));
    hash = sprintf('%.2x', typecast(engine.digest(), 'uint8'));
end
