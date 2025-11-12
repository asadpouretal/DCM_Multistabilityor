function performPEBWithinSubjectModels(dataFolder, modelNames, outputFolder)
% Perform within-subject PEB over multiple models and launch review for best

if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

modelPEBs = struct();  % store PEBs and their F values
Fs = zeros(1, length(modelNames));  % log model evidence per model
bestModel = '';
bestPEB = [];
DCMs_best = {};

for m = 1:length(modelNames)
    model = modelNames{m};
    disp(['Processing model: ', model]);

    % Find all matching DCM files for this model
    dcmFiles = dir(fullfile(dataFolder, '**', sprintf('*%s.mat', model)));
    dcmPaths = fullfile({dcmFiles.folder}, {dcmFiles.name});

    % Load DCMs into cell array
    DCMs = {};
    for i = 1:length(dcmPaths)
        d = load(dcmPaths{i}, 'DCM');
        if isfield(d, 'DCM')
            DCMs{end+1} = d.DCM;
        end
    end

    if isempty(DCMs)
        warning('No DCMs found for model %s. Skipping...', model);
        continue;
    end

    % Second-level design: intercept only
    M = struct();
    M.X = ones(length(DCMs), 1);
    M.Xnames = {'Intercept'};
    M.Q = 'all';
    M.maxit = 256;

    % Estimate PEB
    PEB = spm_dcm_peb(DCMs, M);
    modelPEBs.(matlab.lang.makeValidName(model)) = PEB;
    Fs(m) = PEB.F;

    % Save PEB
    save(fullfile(outputFolder, sprintf('PEB_%s.mat', model)), 'PEB');

    % Track best model
    if Fs(m) == max(Fs)
        bestModel = model;
        bestPEB = PEB;
        DCMs_best = DCMs;
    end
end

% Display comparison
fprintf('\nModel comparison (within-subject PEB):\n');
[~, bestIdx] = max(Fs);
for m = 1:length(modelNames)
    deltaF(m) = Fs(m) - Fs(bestIdx);
    fprintf('  %-6s | F = %.2f | ΔF = %.2f\n', modelNames{m}, Fs(m), deltaF(m));
end

% Plot both Free Energy and DeltaF in one row
figure('Position', [100, 100, 1200, 500]);
cleanNames = strrep(strrep(modelNames, '_', ''), '-', '');

% Subplot 1: Free Energy (F)
subplot(1, 2, 1);
bar(Fs);
ylabel('Free Energy (F)', 'FontWeight', 'bold', 'FontSize', 18);
xlabel('Model', 'FontWeight', 'bold', 'FontSize', 18);
set(gca, 'XTick', 1:length(modelNames), ...
         'XTickLabel', cleanNames, ...
         'LineWidth', 1.5, ...
         'FontSize', 14, ...
         'TickDir', 'out', ...
         'Box', 'off');
title('');

% Subplot 2: ΔF relative to best model
subplot(1, 2, 2);
bar(deltaF);
ylabel('\DeltaF (relative to best)', 'FontWeight', 'bold', 'FontSize', 18);
xlabel('Model', 'FontWeight', 'bold', 'FontSize', 18);
set(gca, 'XTick', 1:length(modelNames), ...
         'XTickLabel', cleanNames, ...
         'LineWidth', 1.5, ...
         'FontSize', 14, ...
         'TickDir', 'out', ...
         'Box', 'off');
yline(0, '--k', 'LineWidth', 1.2);
title('');

% % Save summary table
% T = table(modelNames(:), Fs(:), Fs(:) - max(Fs), ...
%     'VariableNames', {'Model', 'LogEvidence', 'DeltaF'});
% writetable(T, fullfile(outputFolder, 'PEB_model_comparison.csv'));

% % Launch review of best model
% if ~isempty(bestPEB)
%     fprintf('\nReviewing best model: %s (F = %.2f)\n', bestModel, bestPEB.F);
%     spm_dcm_peb_review(bestPEB, DCMs_best);
% end
end
