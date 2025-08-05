function performPEBGroupLevel(dataFolder, modelName, outputFolder)

    % Ensure modelName is a string
    if iscell(modelName)
        modelName = modelName{1};
    end
    % Load all DCMs for the given model
    dcmFiles = dir(fullfile(dataFolder, '**', sprintf('*%s.mat', modelName)));
    dcmPaths = fullfile({dcmFiles.folder}, {dcmFiles.name});

    if isempty(dcmPaths)
        error('No DCM files found for model "%s".', modelName);
    end

    % Load DCMs into a cell array
    DCMs = cell(size(dcmPaths));
    for i = 1:length(dcmPaths)
        load(dcmPaths{i}, 'DCM');
        DCMs{i} = DCM;
    end

    % Build second-level design matrix (intercept only)
    M = struct();
    M.X = ones(length(DCMs), 1);  % Design matrix: group mean
    M.Q = 'all';                  % Use all connection parameters
    M.Xnames = {'Intercept'};
    M.maxit = 256;

    % Fit the PEB model
    disp('Fitting group-level PEB...');
    PEB = spm_dcm_peb(DCMs, M);

    % Optionally perform Bayesian model comparison or reduction
    [BMA, BMR] = spm_dcm_peb_bmc(PEB);

    % Save results
    if ~exist(outputFolder, 'dir'); mkdir(outputFolder); end
    save(fullfile(outputFolder, sprintf('PEB_%s.mat', modelName)), 'PEB', 'BMA', 'BMR');

    % Plot posterior estimates
    spm_dcm_peb_review(PEB, DCMs);  % GUI for reviewing parameter posteriors

    % Optional: display strongest evidence parameters
    disp('Top connections by posterior probability:');
    disp(BMA.Pp);  % Posterior probability for each parameter
end
