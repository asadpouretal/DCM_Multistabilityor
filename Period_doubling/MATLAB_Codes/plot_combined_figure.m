function plot_combined_figure()
    % Directories containing the BMS.mat files for different conditions    
    % Get the full path of the currently executing script
    scriptFullPath = mfilename('fullpath');
    % Extract the directory of the script
    scriptDir = fileparts(scriptFullPath);

    BMS_folder = fullfile(scriptDir, 'BMS');
    correct_trials_dir = BMS_folder;

    % Load BMS.mat files
    PD_trials_file = fullfile(correct_trials_dir,'BMS.mat');

    PD_trials_data = load(PD_trials_file);

    % Extract model names and exceedance probabilities
    model_names = PD_trials_data.BMS.DCM.rfx.family.names;
    correct_xp = PD_trials_data.BMS.DCM.rfx.model.xp;

    % Number of models
    num_models = length(model_names);

    % Combine data for plotting
    data_BMS = [correct_xp]';

    % Labels for x-axis
    x_labels_BMS = {'lat', 'FB', 'FC'}; %model_names;

    % Colors for the bars
    colors = [1, 0, 0;        % Red for error
              0, 0, 1;        % Blue for correct
              0.5, 0, 0.5];   % Purple for all

    % Ground truth values
    ground_truth = [74.802466469706870, 74.802466469706870];

    % DCM Bayesian Averaging results for correct trials
    PD = [PD_trials_data.BMS.DCM.rfx.bma.mEp.A{3}(2,1), PD_trials_data.BMS.DCM.rfx.bma.mEp.A{3}(1,2)];


    % Take the absolute values of the connections
    PD = abs(PD);

    % Combine data for plotting
    data_lateral = [ground_truth; PD]';

    % Labels for x-axis
    x_labels_lateral = {'Column 1 to 2', 'Column 2 to 1'};

    % Colors for the bars
    colors_lateral = [0.5, 0.5, 0.5;  % Gray for ground truth
                      0, 0, 1;        % Blue for correct
                      1, 0, 0;        % Red for error
                      0.5, 0, 0.5];   % Purple for all

    % Create combined figure
    figure('Units', 'normalized', 'Position', [0.1, 0.1, 0.80, 0.60]);
    
    % Plot the first subplot (BMS)
    subplot(1, 2, 1);
    hold on;
    b1 = bar(data_BMS, 'grouped');
    
    % Set colors for each bar group
    for k = 1:length(b1)
        b1(k).FaceColor = colors(k, :);
    end

    % Set x-axis labels
    set(gca, 'XTickLabel', x_labels_BMS, 'XTick', 1:numel(x_labels_BMS));

    % Remove x-ticks but keep x-tick labels
    ax1 = gca;
    ax1.XAxis.TickLength = [0 0];

    % Set y-axis limits
    ylim([0, 1]);

    % Customize axes
    ax1.FontSize = 12;
    ax1.FontWeight = 'bold';
    ax1.XAxis.TickDirection = 'out';
    ax1.YAxis.TickDirection = 'out';
    ax1.XAxis.FontSize = 14; % Increase x-tick labels font size

    % Add labels and set their properties
    ylabel(ax1, 'Model Exceedance Probability', 'FontSize', 18, 'FontWeight', 'bold'); % Increased y-label font size

    % Make x and y axes thicker
    ax1.LineWidth = 2; % Adjust the value as needed for thickness
    hold off;
    
    % Plot the second subplot (Lateral connections)
    subplot(1, 2, 2);
    hold on;
    b2 = bar(data_lateral);
    
    % Set colors for each bar group
    for k = 1:length(b2)
        b2(k).FaceColor = colors_lateral(k, :);
    end

    % Set x-axis labels
    set(gca, 'XTickLabel', x_labels_lateral, 'XTick', 1:numel(x_labels_lateral));

    % Remove x-ticks but keep x-tick labels
    ax2 = gca;
    ax2.XAxis.TickLength = [0 0];

    % Set y-axis limits
    ylim([0, ground_truth(1) * 1.05]);

    % Customize axes
    ax2.FontSize = 12;
    ax2.FontWeight = 'bold';
    ax2.XAxis.TickDirection = 'out';
    ax2.YAxis.TickDirection = 'out';
    ax2.XAxis.FontSize = 14; % Increase x-tick labels font size

    % Add labels and set their properties
    ylabel(ax2, 'Lateral Connection', 'FontSize', 18, 'FontWeight', 'bold'); % Increased y-label font size

    % Make x and y axes thicker
    ax2.LineWidth = 2; % Adjust the value as needed for thickness
    hold off;

    % Add common legend
    lgd = legend({'Ground-truth', 'Est. DCM'}, 'Location', 'northeast');
    lgd.Box = 'off';

    % Save figure
    saveas(gcf, 'Combined_Figure.png');
end
