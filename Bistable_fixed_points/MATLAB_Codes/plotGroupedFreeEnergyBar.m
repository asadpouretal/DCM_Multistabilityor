function plotGroupedFreeEnergyBar(BMS_folder)

    % Set font size and model labels
    w = 18;
    model_labels = {'Lat', 'F-B', 'FC'};
    condition_labels = {'Error', 'Correct', 'All'};

    % Define subfolder paths
    error_trials_dir = fullfile(BMS_folder, 'error_trials');
    correct_trials_dir = fullfile(BMS_folder, 'correct_trials');
    combined_trials_dir = fullfile(BMS_folder, 'combined');

    % Load BMS.mat files
    BMS_err = load(fullfile(error_trials_dir, 'BMS.mat'));
    BMS_corr = load(fullfile(correct_trials_dir, 'BMS.mat'));
    BMS_comb = load(fullfile(combined_trials_dir, 'BMS.mat'));

    % Extract trial-wise free energy
    F_err = BMS_err.BMS.DCM.rfx.F;    % [nTrials x nModels]
    F_corr = BMS_corr.BMS.DCM.rfx.F;
    F_comb = BMS_comb.BMS.DCM.rfx.F;

    % Compute mean across trials
    meanF = [mean(F_err); mean(F_corr); mean(F_comb)]';  % [nModels x nConditions]

    % Set up colour scheme for bars
    colours = [1, 0, 0;    % Red (Error)
               0, 0, 1;    % Blue (Correct)
               0.5, 0, 0.5]; % Purple (All)

    % Create figure
    figure('Name', 'Grouped Free Energy by Condition', ...
           'Units', 'normalized', ...
           'Position', [0.2, 0.4, 0.6, 0.4]);

    % Plot grouped bar chart
    b = bar(meanF, 'grouped'); hold on;

    % Apply colours to each group
    for k = 1:length(b)
        b(k).FaceColor = colours(k, :);
    end

    % Set axes and labels
    set(gca, 'XTickLabel', model_labels, ...
             'XTick', 1:numel(model_labels), ...
             'FontSize', w, ...
             'TickDir', 'out');
    ylabel('Mean Free Energy (F)', 'FontSize', w);
    ylim([min(meanF(:)) - 10, max(meanF(:)) + 10]);  % add padding

    % Legend
    legend(condition_labels, 'Location', 'northeast', 'FontSize', w - 2);
    legend boxoff;

    % Formatting
    box off;
    ax = gca;
    ax.XAxis.TickLength = [0 0];
    ax.LineWidth = 2;
    hold off;

end
