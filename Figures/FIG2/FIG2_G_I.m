
% Create the figure
    clear all
    close all;
    % Parameters
    w = 18;         % Baseline fontsize
    num_trials = 1000;
    fs = 1000;  % Sampling frequency
    decision_boundary = [0.15, 0.10, 0.10, 0.08]; 
    db2 = [0.15, 0.1, 0.1, 0.08]; % Separation between outputs
    a_values = 0.1:0.025:0.3;   % Different evidence quality


    % Directories containing the BMS.mat files for different conditions
    BMS_folder = 'C:\Users\aaa210\OneDrive - University of Sussex\Research projects\DCM validation\Different models test\Two cortical columns\For EEG DCM\BMS';
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

    % Ground truth values
    ground_truth = [0.6, 0.6];

    % DCM Bayesian Averaging results for correct trials
    correct = [correct_trials_data.BMS.DCM.rfx.bma.mEp.A{3}(2, 1), correct_trials_data.BMS.DCM.rfx.bma.mEp.A{3}(1, 2)];

    % DCM Bayesian Averaging results for error trials
    error = [error_trials_data.BMS.DCM.rfx.bma.mEp.A{3}(2, 1), error_trials_data.BMS.DCM.rfx.bma.mEp.A{3}(1, 2)];

    % Connections for all
    all_connections = [combined_trials_data.BMS.DCM.rfx.bma.mEp.A{3}(2, 1), combined_trials_data.BMS.DCM.rfx.bma.mEp.A{3}(1, 2)];


    cl12 = abs([ground_truth(1), correct(1), error(1), all_connections(1)]); % Excitatory connection from column 1 to 2
    cl21 = abs([ground_truth(2), correct(2), error(2), all_connections(2)]); % Excitatory connection from column 2 to 1

    % Initialize result matrices
    acc = zeros(length(a_values), length(cl12));
    avg_decision_rts = zeros(length(a_values), length(cl12));
    avg_error_rts = zeros(length(a_values), length(cl12));

    % Loop through each value of a_values and cl12 to calculate acc and reaction times
    for i = 1:length(a_values)
        for j = 1:length(cl12)
            [acc(i,j), ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, avg_decision_rts(i,j), avg_error_rts(i,j)] = ...
                fsm3(num_trials, fs, decision_boundary(j), a_values(i), db2(j), cl12(j), cl21(j));
        end
    end

    % Calculate the difference measure I
    I = (a_values - 0.1) ./ (a_values + 0.1);    

    

    % Extract model names and exceedance probabilities
    model_names = error_trials_data.BMS.DCM.rfx.family.names;
    error_xp = error_trials_data.BMS.DCM.rfx.model.xp;
    correct_xp = correct_trials_data.BMS.DCM.rfx.model.xp;
    combined_xp = combined_trials_data.BMS.DCM.rfx.model.xp;

    % Combine data for plotting
    data_BMS = [error_xp; correct_xp; combined_xp]';

    % Labels for x-axis
    x_labels_BMS = {'lat.', 'FB', 'FC'}; 

    % Colors for the bars
    colors = [1, 0, 0;        % Red for error
              0, 0, 1;        % Blue for correct
              0.5, 0, 0.5];   % Purple for all

    % Take the absolute values of the connections
    correct = abs(correct);
    error = abs(error);
    all_connections = abs(all_connections);

    % Combine data for plotting
    data_lateral = [ground_truth; correct; error; all_connections]';

    % Labels for x-axis
    x_labels_lateral = {'Column 1 to 2', 'Column 2 to 1'};

    % Colors for the bars
    colors_lateral = [0.5, 0.5, 0.5;  % Gray for ground truth
                      0, 0, 1;        % Blue for correct
                      1, 0, 0;        % Red for error
                      0.5, 0, 0.5];   % Purple for all
        % Create combined figure
    figure('Units', 'normalized', 'Position', [0, 0, 1, 0.70]);

% First plot in the first tile

%%%%%  Figure 1G (BMS)  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(1,3,1);

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
    ylim([0, 1]);
    ylabel('Model Exceedance Probability', 'FontSize', w);

    set(gca, 'TickDir', 'out');
    % Add legend, labels, and formatting
    set(gca, 'FontSize', w);
    set(gca, 'box', 'off')
    %set(gca, 'XColor', 'none');
    %set(gca, 'YColor', 'none');
    ax = gca;  
    ax.LineWidth = 2;     
    hold off;

% Second plot in the second tile
subplot(1,3,2);

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
    ylim([0, ground_truth(1) * 1.05]);
    ylabel('Lateral Connection', 'FontSize', w);

    set(gca, 'FontSize', w);
    set(gca, 'TickDir', 'out');
    % Add legend, labels, and formatting
    set(gca, 'box', 'off')
    
    hold off;
    % Add common legend
    lgd = legend({'Ground-truth', 'Corr. cond.', 'Err. cond.', 'All'}, 'Location', 'northeast','FontSize', w-2);
    lgd.Box = 'off';   

    ax = gca;  
    ax.LineWidth = 2; 


% Get the position of the third subplot
h = subplot(1,3,3);

pos = get(h, 'Position');

% Delete the axes, since we'll replace it with two subplots
delete(h);

% Define the gap between subplots
gap_fraction = 0.1;  % Fraction of the tile's height to use as gap (adjust as desired)
gap = gap_fraction * pos(4);  % Calculate the gap height

% Adjust the heights of the subplots to accommodate the gap
subplot_height = (pos(4) - gap) / 2;

% Position for the first subplot (top half)
pos1 = pos;
pos1(4) = subplot_height;                           % Set the height of the first subplot
pos1(2) = pos(2) + subplot_height + gap;            % Move it up by one subplot height plus the gap

% Position for the second subplot (bottom half)
pos2 = pos;
pos2(4) = subplot_height;                           % Set the height of the second subplot
% pos2(2) remains the same (bottom of the tile)

    % Create the first subplot in the top half
    ax3a = axes('Position', pos1);
    ax3b = axes('Position', pos2);
    axes(ax3a);  % Explicitly make ax3a the active axis
    hold on;     % Ensure "hold on" applies to ax3a    
    plot(ax3a, I*100, acc(:, 2), 'o-', 'LineWidth', 2, 'MarkerSize', 6, 'color', colors_lateral(2, :)); % Correct condition
    plot(ax3a, I*100, acc(:, 3), 'o-', 'LineWidth', 2, 'MarkerSize', 6, 'color', colors_lateral(3, :)); % Error condition
    plot(ax3a, I*100, acc(:, 4), 'o-', 'LineWidth', 2, 'MarkerSize', 6, 'color', colors_lateral(4, :)); % All condition

    ylabel(ax3a,"Acc. (%)", 'FontSize', w)
    set(ax3a, 'FontSize', w);
    ax = ax3a;  
    ax.LineWidth = 2; 
    set(ax3a, 'TickDir', 'out');
    set(ax3a, 'box', 'off')
    %set(ax3a, 'XColor', 'none');
    set(ax3a,'XTickLabel', []);


    % Create the second subplot in the bottom half
    % Normalize reaction times
    no_avg_decision_rts = zeros(size(avg_decision_rts));
    no_avg_error_rts = zeros(size(avg_error_rts));
    
    for i = 1:length(cl12)
        g = [avg_decision_rts(:,i)' avg_error_rts(:,i)']; 
        no_avg_decision_rts(:,i) = (avg_decision_rts(:,i) - nanmin(g)) ./ (nanmax(g) - nanmin(g));
        no_avg_error_rts(:,i) = (avg_error_rts(:,i) - nanmin(g)) ./ (nanmax(g) - nanmin(g));
    end

    axes(ax3b);  % Explicitly make ax3b the active axis
    hold on;     % Ensure "hold on" applies to ax3b  
    plot(ax3b,I*100, no_avg_decision_rts(:, 2), 'o-', 'LineWidth', 2, 'MarkerSize', 6, 'color', colors_lateral(2, :)); % Correct condition
    plot(ax3b,I(1:5)*100, no_avg_error_rts(1:5, 2), 'o--', 'LineWidth', 2, 'MarkerSize', 6, 'color', colors_lateral(2, :), 'HandleVisibility', 'off'); % Correct condition (error)
    plot(ax3b,I*100, no_avg_decision_rts(:, 3), 'o-', 'LineWidth', 2, 'MarkerSize', 6, 'color', colors_lateral(3, :), 'HandleVisibility', 'off'); % Error condition
    plot(ax3b,I(1:5)*100, no_avg_error_rts(1:5, 3), 'o--', 'LineWidth', 2, 'MarkerSize', 6, 'color', colors_lateral(3, :), 'HandleVisibility', 'off'); % Error condition (error)
    plot(ax3b,I*100, no_avg_decision_rts(:, 4), 'o-', 'LineWidth', 2, 'MarkerSize', 6, 'color', colors_lateral(4, :), 'HandleVisibility', 'off'); % All condition
    plot(ax3b,I(1:5)*100, no_avg_error_rts(1:5, 4), 'o--', 'LineWidth', 2, 'MarkerSize', 6, 'color', colors_lateral(4, :), 'HandleVisibility', 'off'); % All condition (error)
    box off;
    % Create invisible dummy plots for the legend
    h1 = plot(nan, nan, 'k-', 'LineWidth', 2);  % Solid line for correct
    h2 = plot(nan, nan, 'k--', 'LineWidth', 2); % Dashed line for error
    % Assign legend to the dummy plots
    legend(ax3b, [h1, h2], {'Corr.', 'Err.'}, 'Location', 'northeast', 'FontSize', w-2 , 'TextColor', 'k');
    legend boxoff;
    hold off;    


    xlabel(ax3b,'\epsilon (%)', 'FontSize', w)
    ylabel(ax3b,'NDT (a.u.)', 'FontSize', w)
    legend boxoff
    ax = ax3b;  
    ax.LineWidth = 2; 
    set(ax3b, 'TickDir', 'out');
    set(ax3b, 'FontSize', w);
    set(ax3b, 'box', 'off')
