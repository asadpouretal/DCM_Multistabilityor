
    % Directories containing the BMS.mat files for different conditions
    BMS_folder = 'C:\Users\se16008969\OneDrive - Ulster University\Research projects\DCM validation\Different models test\Two cortical columns\For EEG DCM\Code\BMS';
    error_trials_dir = fullfile(BMS_folder, 'error_trials');
    correct_trials_dir = fullfile(BMS_folder, 'correct_trials');
    combined_trials_dir = fullfile(BMS_folder,'combined');

    % Load BMS.mat files
    error_trials_file = fullfile(error_trials_dir, 'BMS.mat');
    correct_trials_file = fullfile(correct_trials_dir, 'BMS.mat');
    combined_trials_file = fullfile(combined_trials_dir, 'BMS.mat');

    error_trials_data = load(error_trials_file);
    correct_trials_data = load(correct_trials_file);
    combined_trials_data = load(combined_trials_file);

    % Extract model names and exceedance probabilities
    model_names = error_trials_data.BMS.DCM.rfx.family.names;
    error_xp = error_trials_data.BMS.DCM.rfx.model.xp;
    correct_xp = correct_trials_data.BMS.DCM.rfx.model.xp;
    combined_xp = combined_trials_data.BMS.DCM.rfx.model.xp;

    % Number of models
    num_models = length(model_names);

    % Combine data for plotting
    data = [error_xp; correct_xp; combined_xp]';

    % Labels for x-axis
    x_labels = {'lateral', 'forward-backward'}; %model_names;

    % Colors for the bars
    colors = [1, 0, 0;        % Red for error
              0, 0, 1;        % Blue for correct
              0.5, 0, 0.5];   % Purple for all

    % Create bar plot
    figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.50, 0.40]);
    hold on;

    b = bar(data, 'grouped');

    % Set colors for each bar group
    for k = 1:length(b)
        b(k).FaceColor = colors(k, :);
    end

    % Set x-axis labels
    set(gca, 'XTickLabel', x_labels, 'XTick', 1:numel(x_labels));

    % Remove x-ticks but keep x-tick labels
    ax = gca;
    ax.XAxis.TickLength = [0 0];

    % Set y-axis limits
    ylim([0, 1]);

    % Set legend and remove box
    lgd = legend({'Error cond.', 'Correct cond.', 'All'}, 'Location', 'northeast');
    lgd.Box = 'off';

    % Customize axes
    ax.FontSize = 12;
    ax.FontWeight = 'bold';
    ax.XAxis.TickDirection = 'out';
    ax.YAxis.TickDirection = 'out';
    ax.XAxis.FontSize = 14; % Increase x-tick labels font size

    % Add labels and set their properties
    ylabel(ax, 'Model Exceedance Probability', 'FontSize', 18, 'FontWeight', 'bold'); % Increased y-label font size
    
    % Make x and y axes thicker
    ax.LineWidth = 2; % Adjust the value as needed for thickness

    hold off;

    % Save figure
    saveas(gcf, 'Model_Exceedance_Probability.png');


