function performDCMPEBAnalysis(dataFolder, modelNames, outputFolder)
    % performDCMPEBAnalysis - Performs Parametric Empirical Bayes (PEB) analysis
    % and model comparison for DCM models
    %
    % Inputs:
    %    dataFolder - Path to the folder containing the DCM files
    %    modelNames - Cell array of model names
    %    outputFolder - Output directory for results
    
    spm('defaults', 'EEG');
    spm_jobman('initcfg');
    
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end
    
    % Collect DCM files and organize by model type
    fprintf('Collecting DCM files...\n');
    [DCMs, trialInfo] = collectDCMFiles(dataFolder, modelNames);
    
    if isempty(DCMs)
        error('No complete DCM sets found');
    end
    
    % Perform model comparison based on free energy
    fprintf('Performing model comparison...\n');
    modelComparison = compareModelsLogEvidence(DCMs, modelNames, outputFolder);
    
    % % Perform PEB analysis for the winning model
    % fprintf('Performing PEB analysis...\n');
    % winningModelIdx = modelComparison.bestModel;
    % PEB_results = performPEB(DCMs{winningModelIdx}, trialInfo, outputFolder);
    
    % % Save all results
    % save(fullfile(outputFolder, 'DCM_Analysis_Results.mat'), ...
    %      'modelComparison', 'PEB_results', 'modelNames', 'trialInfo');
    % 
    % % Generate report
    % generateAnalysisReport(modelComparison, PEB_results, modelNames, outputFolder);
end

function [DCMs, trialInfo] = collectDCMFiles(dataFolder, modelNames)
    % Collect and organize DCM files by model type
    
    files = dir(fullfile(dataFolder, '**', '*.mat'));
    nModels = length(modelNames);
    
    % Initialize storage using a structure instead of containers.Map
    trialData = struct();
    
    % Parse files and organize by trial
    for i = 1:length(files)
        [~, name, ~] = fileparts(files(i).name);
        tokens = regexp(name, 'DCM_Model_Trial_(\d+)_(.+)$', 'tokens');
        
        if ~isempty(tokens)
            trialNum = str2double(tokens{1}{1});
            modelName = tokens{1}{2};
            
            % Find model index
            modelIdx = find(strcmp(modelNames, modelName));
            if isempty(modelIdx)
                continue;
            end
            
            % Create field name for this trial
            trialField = sprintf('Trial_%d', trialNum);
            
            % Initialize trial structure if it doesn't exist
            if ~isfield(trialData, trialField)
                trialData.(trialField) = struct('files', {cell(1, nModels)}, ...
                                               'trial', trialNum, ...
                                               'complete', false);
            end
            
            % Store file path
            trialData.(trialField).files{modelIdx} = fullfile(files(i).folder, files(i).name);
        end
    end
    
    % Check completeness and load DCMs
    DCMs = cell(1, nModels);
    for m = 1:nModels
        DCMs{m} = {};
    end
    
    trialInfo = [];
    trialFields = fieldnames(trialData);
    validTrialIdx = 0;
    
    for t = 1:length(trialFields)
        trial = trialData.(trialFields{t});
        
        % Check if all models exist for this trial
        if all(~cellfun(@isempty, trial.files))
            validTrialIdx = validTrialIdx + 1;
            
            % Load DCMs for each model
            for m = 1:nModels
                temp = load(trial.files{m}, 'DCM');
                DCMs{m}{validTrialIdx} = temp.DCM;
            end
            
            trialInfo(validTrialIdx).trial = trial.trial;
        end
    end
    
    fprintf('Found %d complete trials with all %d models\n', validTrialIdx, nModels);
end

function modelComparison = compareModelsLogEvidence(DCMs, modelNames, outputFolder)
    % Compare models based on log evidence (free energy)
    
    nModels = length(modelNames);
    nTrials = length(DCMs{1});
    
    % Extract free energies
    F = zeros(nTrials, nModels);
    for m = 1:nModels
        for t = 1:nTrials
            F(t, m) = DCMs{m}{t}.F;
        end
    end
    
    % Calculate log Bayes factors (relative to first model)
    logBF = zeros(nTrials, nModels);
    for m = 2:nModels
        logBF(:, m) = F(:, m) - F(:, 1);
    end
    
    % Calculate mean log evidence across trials
    meanF = mean(F, 1);
    stdF = std(F, 0, 1);
    
    % Determine best model
    [~, bestModel] = max(meanF);
    
    % Create comparison structure
    modelComparison = struct();
    modelComparison.F = F;
    modelComparison.logBF = logBF;
    modelComparison.meanF = meanF;
    modelComparison.stdF = stdF;
    modelComparison.bestModel = bestModel;
    
    figure('Position', [100, 100, 1200, 800]);

    cleanNames = strrep(strrep(modelNames, '_', ''), '-', '');

    % Subplot 1: Free energy by trial
    subplot(2, 2, 1);
    plot(F, 'LineWidth', 2);
    xlabel('Trial', 'FontWeight', 'bold', 'FontSize', 18);
    ylabel('Free Energy (F)', 'FontWeight', 'bold', 'FontSize', 18);
    legend(cleanNames, 'Location', 'best');
    set(gca, 'LineWidth', 1.5, 'FontSize', 14, ...
             'TickDir', 'out', 'Box', 'off');
    title('');

    % Subplot 2: Mean free energy with error bars
    subplot(2, 2, 2);
    bar(1:nModels, meanF);
    hold on;
    errorbar(1:nModels, meanF, stdF, 'k.', 'LineWidth', 2);
    xlabel('Model', 'FontWeight', 'bold', 'FontSize', 18);
    ylabel('Mean Free Energy', 'FontWeight', 'bold', 'FontSize', 18);
    set(gca, 'XTickLabel', cleanNames, ...
             'LineWidth', 1.5, 'FontSize', 14, ...
             'TickDir', 'out', 'Box', 'off');
    title('');

    % Subplot 3: Log Bayes factors
    subplot(2, 2, 3);
    bar(mean(logBF, 1));
    xlabel('Model', 'FontWeight', 'bold', 'FontSize', 18);
    ylabel(['Log Bayes Factor (rel. to ' cleanNames{1} ' model)'], 'FontWeight', 'bold', 'FontSize', 18);
    set(gca, 'XTickLabel', cleanNames, ...
             'LineWidth', 1.5, 'FontSize', 14, ...
             'TickDir', 'out', 'Box', 'off');
    title('');

    % Subplot 4: Distribution of free energies
    subplot(2, 2, 4);
    boxplot(F, 'Labels', cleanNames);
    ylabel('Free Energy', 'FontWeight', 'bold', 'FontSize', 18);
    set(gca, 'LineWidth', 1.5, 'FontSize', 14, ...
             'TickDir', 'out', 'Box', 'off');
    title('');
    
    saveas(gcf, fullfile(outputFolder, 'Model_Comparison.png'));
    
    % Print summary
    fprintf('\n=== Model Comparison Results ===\n');
    for m = 1:nModels
        fprintf('%s: Mean F = %.2f (±%.2f)\n', modelNames{m}, meanF(m), stdF(m));
    end
    fprintf('Best model: %s\n', modelNames{bestModel});
    fprintf('================================\n');
end

function PEB_results = performPEB(DCMs, trialInfo, outputFolder)
    % Perform Parametric Empirical Bayes analysis
    
    fprintf('Setting up PEB analysis...\n');
    
    % Setup design matrix for second-level analysis
    nTrials = length(DCMs);
    X = ones(nTrials, 1);  % Grand mean
    
    % You can add covariates here if available
    % For example, if you have trial difficulty or reaction times:
    % X(:,2) = zscore(difficulty);
    
    % Specify PEB settings
    M = struct();
    M.X = X;
    M.Xnames = {'Mean'};
    M.Q = 'all';  % Estimate all parameters
    
    % Perform PEB analysis
    fprintf('Running PEB...\n');
    PEB = spm_dcm_peb(DCMs, M);
    
    % If PEB returns multiple structures, take the first one
    if length(PEB) > 1
        fprintf('Multiple PEB structures returned, using the first one.\n');
        PEB = PEB(1);
    end
    
    % Compute posterior probabilities and add to PEB structure
    PEB.Pp = computePosteriorProbabilities(PEB);
    
    % Store results
    PEB_results = struct();
    PEB_results.PEB = PEB;
    
    % Visualize PEB results
    visualizePEBResults(PEB, outputFolder);
    
    % Save PEB for interactive review
    save(fullfile(outputFolder, 'PEB_model.mat'), 'PEB');
    
    % Save all results
    save(fullfile(outputFolder, 'PEB_results.mat'), 'PEB_results');
    
    % Extract and display key connectivity parameters
    displayConnectivityResults(PEB, DCMs{1});
end

function generateAnalysisReport(modelComparison, PEB_results, modelNames, outputFolder)
    % Generate a comprehensive analysis report
    
    reportFile = fullfile(outputFolder, 'DCM_Analysis_Report.txt');
    fid = fopen(reportFile, 'w');
    
    fprintf(fid, 'DCM Analysis Report\n');
    fprintf(fid, '==================\n\n');
    fprintf(fid, 'Generated: %s\n\n', datestr(now));
    
    fprintf(fid, '1. Model Comparison\n');
    fprintf(fid, '-------------------\n');
    for m = 1:length(modelNames)
        fprintf(fid, '%s:\n', modelNames{m});
        fprintf(fid, '  Mean Free Energy: %.2f (±%.2f)\n', ...
                modelComparison.meanF(m), modelComparison.stdF(m));
        if m > 1
            fprintf(fid, '  Mean Log BF vs %s: %.2f\n', ...
                    modelNames{1}, mean(modelComparison.logBF(:, m)));
        end
        fprintf(fid, '\n');
    end
    fprintf(fid, 'Best Model: %s\n\n', modelNames{modelComparison.bestModel});
    
    fprintf(fid, '2. PEB Results Summary\n');
    fprintf(fid, '----------------------\n');
    
    % Get PEB structure
    PEB = PEB_results.PEB;
    
    fprintf(fid, 'Number of parameters: %d\n', length(PEB.Ep));
    fprintf(fid, 'Free energy of PEB model: %.2f\n', PEB.F);
    
    % Count significant parameters using computed Pp
    if isfield(PEB, 'Pp')
        sig_params = sum(PEB.Pp > 0.95);
        fprintf(fid, 'Significant parameters (Pp > 0.95): %d\n\n', sig_params);
        
        % List top 10 significant parameters
        [sorted_Pp, idx] = sort(PEB.Pp, 'descend');
        fprintf(fid, 'Top 10 Parameters by Posterior Probability:\n');
        fprintf(fid, '%-20s %-15s %-15s %-10s\n', 'Parameter', 'Estimate', 'Std Error', 'Pp');
        fprintf(fid, '%s\n', repmat('-', 1, 60));
        
        for i = 1:min(10, length(idx))
            param_idx = idx(i);
            estimate = PEB.Ep(param_idx);
            std_error = sqrt(PEB.Cp(param_idx, param_idx));
            pp = sorted_Pp(i);
            
            % Get parameter name if available
            if isfield(PEB, 'Pnames') && length(PEB.Pnames) >= param_idx
                param_name = PEB.Pnames{param_idx};
            else
                param_name = sprintf('Param %d', param_idx);
            end
            
            fprintf(fid, '%-20s %-15.4f %-15.4f %-10.3f\n', ...
                    param_name, estimate, std_error, pp);
        end
    else
        fprintf(fid, 'Posterior probabilities not computed.\n');
    end
    
    fprintf(fid, '\n3. Analysis Details\n');
    fprintf(fid, '-------------------\n');
    fprintf(fid, 'Number of trials/subjects analyzed: %d\n', size(PEB.M.X, 1));
    fprintf(fid, 'Number of covariates: %d\n', size(PEB.M.X, 2));
    
    if isfield(PEB.M, 'Xnames')
        fprintf(fid, 'Covariates: %s\n', strjoin(PEB.M.Xnames, ', '));
    end
    
    fclose(fid);
    fprintf('Report saved to: %s\n', reportFile);
end

function displayConnectivityResults(PEB, exampleDCM)
    % Display connectivity parameter results from PEB
    
    fprintf('\n=== PEB Connectivity Results ===\n');
    
    % Use Pp if available, otherwise compute it
    if isfield(PEB, 'Pp')
        Pp = PEB.Pp;
    else
        Pp = computePosteriorProbabilities(PEB);
    end
    
    % Get parameter names if available
    if isfield(PEB, 'Pnames')
        pnames = PEB.Pnames;
    else
        pnames = arrayfun(@(x) sprintf('Parameter %d', x), 1:length(PEB.Ep), 'UniformOutput', false);
    end
    
    % Display significant connections
    threshold = 0.95;
    fprintf('\nSignificant parameters (Pp > %.2f):\n', threshold);
    fprintf('%-40s %-12s %-12s %-12s\n', 'Parameter', 'Estimate', 'Std Error', 'Pp');
    fprintf('%s\n', repmat('-', 1, 80));
    
    sig_idx = find(Pp > threshold);
    if isempty(sig_idx)
        fprintf('No parameters exceed threshold.\n');
    else
        % Sort by Pp for display
        [~, sort_order] = sort(Pp(sig_idx), 'descend');
        sig_idx_sorted = sig_idx(sort_order);
        
        for i = 1:min(20, length(sig_idx_sorted))  % Show top 20
            idx = sig_idx_sorted(i);
            se = sqrt(PEB.Cp(idx, idx));
            fprintf('%-40s %-12.4f %-12.4f %-12.3f\n', ...
                    pnames{idx}, PEB.Ep(idx), se, Pp(idx));
        end
        
        if length(sig_idx) > 20
            fprintf('... and %d more significant parameters\n', length(sig_idx) - 20);
        end
    end
    
    fprintf('\nSummary:\n');
    fprintf('Total parameters: %d\n', length(PEB.Ep));
    fprintf('Significant parameters: %d (%.1f%%)\n', ...
            length(sig_idx), 100*length(sig_idx)/length(PEB.Ep));
    fprintf('PEB Free Energy: %.2f\n', PEB.F);
    fprintf('===============================\n');
end

function visualizePEBResults(PEB, outputFolder)
    % Create comprehensive visualization of PEB results
    
    % Figure 1: Parameter estimates and uncertainty
    figure('Position', [100, 100, 1200, 900]);
    
    % Subplot 1: Parameter estimates with error bars
    subplot(3, 2, 1);
    nParams = length(PEB.Ep);
    
    % Create error bar plot manually
    errorbar(1:nParams, PEB.Ep, sqrt(diag(PEB.Cp)), 'o', 'LineWidth', 1.5);
    hold on;
    plot([0 nParams+1], [0 0], 'k--');
    xlabel('Parameter');
    ylabel('Estimate');
    title('PEB Parameter Estimates (±SE)');
    grid on;
    xlim([0 nParams+1]);
    
    % Subplot 2: Posterior probabilities
    subplot(3, 2, 2);
    Pp = computePosteriorProbabilities(PEB);
    bar(Pp);
    hold on;
    plot([0 length(Pp)+1], [0.95 0.95], 'r--', 'LineWidth', 2);
    xlabel('Parameter');
    ylabel('Posterior Probability');
    title('Probability of Parameters > 0');
    ylim([0 1]);
    grid on;
    
    % Subplot 3: Between-subject variance
    subplot(3, 2, 3);
    imagesc(PEB.Ce);
    colorbar;
    xlabel('Parameter');
    ylabel('Parameter');
    title('Between-subject Covariance (Ce)');
    axis square;
    
    % Subplot 4: Design matrix
    subplot(3, 2, 4);
    imagesc(PEB.M.X);
    colorbar;
    xlabel('Covariate');
    ylabel('Subject/Trial');
    title('Second-level Design Matrix');
    set(gca, 'XTick', 1:size(PEB.M.X, 2));
    if isfield(PEB.M, 'Xnames')
        set(gca, 'XTickLabel', PEB.M.Xnames);
    end
    
    % Subplot 5: Significant parameters
    subplot(3, 2, 5);
    sig_idx = find(Pp > 0.95);
    if ~isempty(sig_idx)
        stem(sig_idx, PEB.Ep(sig_idx), 'filled');
        xlabel('Parameter Index');
        ylabel('Estimate');
        title(sprintf('Significant Parameters (Pp > 0.95, n=%d)', length(sig_idx)));
        grid on;
    else
        text(0.5, 0.5, 'No significant parameters at Pp > 0.95', ...
             'HorizontalAlignment', 'center');
        axis off;
    end
    
    % Subplot 6: Model evidence
    subplot(3, 2, 6);
    text(0.1, 0.8, sprintf('PEB Free Energy: %.2f', PEB.F), 'FontSize', 14);
    text(0.1, 0.6, sprintf('Number of parameters: %d', length(PEB.Ep)), 'FontSize', 12);
    text(0.1, 0.4, sprintf('Number of subjects/trials: %d', size(PEB.M.X, 1)), 'FontSize', 12);
    text(0.1, 0.2, sprintf('Significant parameters: %d', sum(Pp > 0.95)), 'FontSize', 12);
    axis off;
    
    saveas(gcf, fullfile(outputFolder, 'PEB_Results_Overview.png'));
    
    % Figure 2: Detailed parameter analysis
    figure('Position', [100, 100, 1000, 600]);
    
    % Sort parameters by posterior probability
    [sorted_Pp, sort_idx] = sort(Pp, 'descend');
    
    % Plot top parameters
    n_show = min(20, length(sorted_Pp));
    
    subplot(1, 2, 1);
    barh(1:n_show, PEB.Ep(sort_idx(1:n_show)));
    hold on;
    % Add error bars
    for i = 1:n_show
        errorbar(PEB.Ep(sort_idx(i)), i, ...
                 sqrt(PEB.Cp(sort_idx(i), sort_idx(i))), ...
                 'horizontal', 'k', 'LineWidth', 1.5);
    end
    set(gca, 'YTick', 1:n_show);
    set(gca, 'YTickLabel', arrayfun(@(x) sprintf('Param %d', x), sort_idx(1:n_show), 'UniformOutput', false));
    xlabel('Parameter Estimate');
    title('Top Parameters by Posterior Probability');
    grid on;
    
    subplot(1, 2, 2);
    barh(1:n_show, sorted_Pp(1:n_show));
    hold on;
    plot([0.95 0.95], [0 n_show+1], 'r--', 'LineWidth', 2);
    set(gca, 'YTick', 1:n_show);
    set(gca, 'YTickLabel', arrayfun(@(x) sprintf('Param %d', x), sort_idx(1:n_show), 'UniformOutput', false));
    xlabel('Posterior Probability');
    xlim([0 1]);
    title('Posterior Probabilities (sorted)');
    grid on;
    
    saveas(gcf, fullfile(outputFolder, 'PEB_Top_Parameters.png'));
    
    % Figure 3: Connectivity-specific visualization if parameter names are available
    if isfield(PEB, 'Pnames')
        plotConnectivitySpecificResults(PEB, Pp, outputFolder);
    end
end

function plotConnectivitySpecificResults(PEB, Pp, outputFolder)
    % Create connectivity-specific plots
    
    figure('Position', [100, 100, 1200, 800]);
    
    % Parse parameter names to identify connectivity types
    A_params = [];
    B_params = [];
    C_params = [];
    
    for i = 1:length(PEB.Pnames)
        pname = PEB.Pnames{i};
        if startsWith(pname, 'A')
            A_params(end+1) = i;
        elseif startsWith(pname, 'B')
            B_params(end+1) = i;
        elseif startsWith(pname, 'C')
            C_params(end+1) = i;
        end
    end
    
    % Plot A parameters (intrinsic connectivity)
    if ~isempty(A_params)
        subplot(2, 2, 1);
        bar(PEB.Ep(A_params));
        hold on;
        errorbar(1:length(A_params), PEB.Ep(A_params), ...
                 sqrt(diag(PEB.Cp(A_params, A_params))), ...
                 'k.', 'LineWidth', 1.5);
        xlabel('A Parameter Index');
        ylabel('Estimate');
        title('Intrinsic Connectivity (A matrix)');
        grid on;
        
        subplot(2, 2, 2);
        bar(Pp(A_params));
        hold on;
        plot([0 length(A_params)+1], [0.95 0.95], 'r--');
        xlabel('A Parameter Index');
        ylabel('Posterior Probability');
        title('A Parameters: Pp > 0');
        ylim([0 1]);
        grid on;
    end
    
    % Plot C parameters (driving inputs)
    if ~isempty(C_params)
        subplot(2, 2, 3);
        bar(PEB.Ep(C_params));
        hold on;
        errorbar(1:length(C_params), PEB.Ep(C_params), ...
                 sqrt(diag(PEB.Cp(C_params, C_params))), ...
                 'k.', 'LineWidth', 1.5);
        xlabel('C Parameter Index');
        ylabel('Estimate');
        title('Driving Inputs (C matrix)');
        grid on;
        
        subplot(2, 2, 4);
        bar(Pp(C_params));
        hold on;
        plot([0 length(C_params)+1], [0.95 0.95], 'r--');
        xlabel('C Parameter Index');
        ylabel('Posterior Probability');
        title('C Parameters: Pp > 0');
        ylim([0 1]);
        grid on;
    end
    
    saveas(gcf, fullfile(outputFolder, 'PEB_Connectivity_Analysis.png'));
end

function Pp = computePosteriorProbabilities(PEB)
    % Compute posterior probability that parameters are greater than zero
    
    % Get posterior mean and covariance
    Ep = PEB.Ep(:);
    Cp = PEB.Cp;
    
    % Ensure Cp is a full matrix
    if isvector(Cp)
        Cp = diag(Cp);
    end
    
    % Compute posterior probability for each parameter
    Pp = zeros(size(Ep));
    for i = 1:length(Ep)
        % Standard deviation for this parameter
        var_i = Cp(i,i);
        if var_i > 0
            sd = sqrt(var_i);
            % Probability that parameter > 0
            Pp(i) = 1 - spm_Ncdf(0, Ep(i), var_i);
        else
            Pp(i) = double(Ep(i) > 0);
        end
    end
end