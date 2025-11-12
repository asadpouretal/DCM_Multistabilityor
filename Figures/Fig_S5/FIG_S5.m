% clear all,
figure,

    % Colors for the bars
    colors_lateral = [0.5, 0.5, 0.5;  % Gray for ground truth
                      0, 0, 1;        % Blue for correct
                      1, 0, 0;        % Red for error
                      0.5, 0, 0.5];   % Purple for all
w=26;   

%% %%%  Figure S5A  %% Needs Amin's Modification

load("model1")
load("model2") 

subplot(1,2,1)

    % Colors for the bars
    colors_lateral = [0.5, 0.5, 0.5;  % Gray for ground truth
                      0, 0, 1;        % Blue for correct
                      1, 0, 0;        % Red for error
                      0.5, 0, 0.5];   % Purple for all

plot(ts,ch_norm,'LineWidth',2,'color', colors_lateral(1, :))
hold on
plot(ts, chh_norm, 'LineWidth', 2, 'color', colors_lateral(2, :))

xlim([0 2])
% 
ax = gca;  
ax.LineWidth = 2; 
set(gca, 'TickDir', 'out','FontSize', 26);
% % Add legend, labels, and formatting
% %legend('Column 1', 'Column 2','FontSize', 24)
xlabel('Time (s)', 'FontSize', 26)
ylabel('Normalised EPSP of {e}^1_1 (a.u.)', 'FontSize', 26)
set(gca, 'FontSize', 26);
set(gca, 'box', 'off')
xticks([0,0.5,1,1.5,2])


axis square
legend('Ground-truth','Estimated','FontSize', 24,'location','southeast')
legend boxoff


%% %%%  Figure S5B  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h = subplot(1,2,2);
pos = get(h, 'Position');

% Delete the axes, since we'll replace it with two subplots
delete(h);

    % Directories containing the BMS.mat files for different conditions    
    BMSDir = 'C:\Users\aaa210\OneDrive - University of Sussex\Research projects\DCM validation\Different models test\GitHub\Single_point_steady_state\single_balanced_lateral_model';

    BMS_folder = fullfile(BMSDir, 'BMS');
    correct_trials_dir = BMS_folder;

    % Load BMS.mat files
    PD_trials_file = fullfile(correct_trials_dir,'BMS.mat');

    PD_trials_data = load(PD_trials_file);

    % Extract model names and exceedance probabilities
    model_names = PD_trials_data.BMS.DCM.rfx.family.names;
    PD_xp = PD_trials_data.BMS.DCM.rfx.model.xp;

    % Number of models
    num_models = length(model_names);

    % Combine data for plotting
    data_BMS = [PD_xp]';

    % Labels for x-axis
    x_labels_BMS = {'lat.', 'FB', 'FC'}; %model_names;

    % Colors for the bars
    colors = [0, 0, 0;        % Red for error
              0, 0, 1;        % Blue for correct
              0.5, 0, 0.5];   % Purple for all

    % Ground truth values
    ground_truth = [144, 144];

    % DCM Bayesian Averaging results for correct trials
    PD = [PD_trials_data.BMS.DCM.rfx.bma.mEp.A{3}(2,1), PD_trials_data.BMS.DCM.rfx.bma.mEp.A{3}(1,2)];


    % Take the absolute values of the connections
    PD = abs(PD);

    % Combine data for plotting
    data_lateral = [ground_truth; PD]';

    % Labels for x-axis
    x_labels_lateral = {'Column 1 to 2', 'Column 2 to 1'};



% Define the gap between subplots
gap_fraction = 0.25;  % Fraction of the tile's width to use as gap (adjust as desired)
gap = gap_fraction * pos(3);  % Calculate the gap width

% Adjust the widths of the subplots to accommodate the gap
subplot_width = (pos(3) - gap) / 2;

% Position for the first subplot (left column)
pos1 = pos;
pos1(3) = subplot_width;                           % Set the width of the first subplot
% pos1(1) remains the same (left edge)

% Position for the second subplot (right column)
pos2 = pos;
pos2(3) = subplot_width;                           % Set the width of the second subplot
pos2(1) = pos(1) + subplot_width + gap;            % Move it to the right by one subplot width plus the gap

% Create the first subplot (left column)
ax3a = axes('Position', pos1);
axes(ax3a);  % Explicitly make ax3a the active axis
hold on;     % Ensure "hold on" applies to ax3a    

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

set(gca, 'TickDir', 'out');
% Add legend, labels, and formatting
set(gca, 'FontSize', w);
set(gca, 'box', 'off');
ax = gca;  
ax.LineWidth = 2;     
hold off;    
set(ax3a, 'FontSize', w);
ylabel('Model Exceedance Probability', 'FontSize', w, 'FontWeight','bold');
ylim([0 0.65])

ax = ax3a;  
ax.LineWidth = 2; 
set(ax3a, 'TickDir', 'out');
set(ax3a, 'box', 'off');

% Create the second subplot (right column)
ax3b = axes('Position', pos2);
axes(ax3b);  % Explicitly make ax3b the active axis
hold on;     % Ensure "hold on" applies to ax3b  

b2 = bar(data_lateral);

% Set colors for each bar group
for k = 1:length(b2)
    b2(k).FaceColor = colors_lateral(k, :);
end

% Set x-axis labels
set(gca, 'XTickLabel', x_labels_lateral, 'XTick', 1:numel(x_labels_lateral), 'YScale', 'log');

% Remove x-ticks but keep x-tick labels
ax2 = gca;
ax2.XAxis.TickLength = [0 0];  
% Set y-axis limits
% ylim([-0.001, ground_truth(1) * 1.05]);
set(ax3b, 'FontSize', w);
ylabel(ax3b, 'Lateral Connection (log scale)', 'FontSize', w, 'FontWeight','bold'); % Increased y-label font size
ax = ax3b;  
ax.LineWidth = 2; 
set(ax3b, 'TickDir', 'out');

set(ax3b, 'box', 'off');