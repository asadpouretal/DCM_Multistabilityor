figure('Units', 'normalized', 'Position', [0, 0, 1, 1]);

    % Colors for the bars
    colors_lateral = [0.5, 0.5, 0.5;  % Gray for ground truth
                      0, 0, 1;        % Blue for correct
                      1, 0, 0;        % Red for error
                      0.5, 0, 0.5];   % Purple for all

%%%%%  Figure 2D  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load("3D&E.mat")
load("3g pd.mat")
load('fig3_PD.mat');

w=20;
subplot(2,3,1)

plot(ts,no1,'LineWidth',2,'color', colors_lateral(1, :))
hold on
plot(ts, noo1, 'LineWidth', 1, 'color', colors_lateral(2, :))
xlim([0 0.75])

ax = gca;  
ax.LineWidth = 2; 
set(gca, 'TickDir', 'out');
% Add legend, labels, and formatting
%legend('Column 1', 'Column 2','FontSize', 24)
%xlabel('Time (s)', 'FontSize', 26)
%ylabel('NMP of e_1 (a.u.)', 'FontSize', 26)
set(gca, 'FontSize', w);
set(gca, 'box', 'off')
xticks([0,0.25,0.5,0.75])
xticklabels({});
h = ylabel('Normalised EPSP of {e}^1_1 (a.u.)', 'FontSize', w, 'FontWeight','bold');

% Adjust the position of the x-label
% currentPos = get(h, 'Position');  % Get current position [x, y, z]
% newYPos = currentPos(2)-0.8 ;    % Adjust the y-position (move up by increasing y-value)
% set(h, 'Position', [currentPos(1), newYPos, currentPos(3)]);  % Apply the new position

%title('Period-doubling - \lambda = 0.03')
% axis square
legend('Ground-truth','Estimated','FontSize', w-2,'location','southeast')
legend boxoff
% t = title('Period-doubling');
% set(t, 'Position', get(t, 'Position') + [0.6 0 0]); % Move left by 1 unit
%%%%%  Figure 2E  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load("3D&E.mat")

subplot(2,3,2)
plot3(no2(fs:end)*nan,no3(fs:end)*nan,no1(fs:end)*nan,'LineWidth', 2,'LineStyle', '-','color', colors_lateral(1, :))
hold on
plot3(noo2(fs:end)*nan,noo3(fs:end)*nan,noo1(fs:end)*nan,'LineWidth', 2,'LineStyle', '-','color', colors_lateral(2, :))
hold on
plot3(no2(fs:end),no3(fs:end),no1(fs:end),'.','MarkerSize',6,'color', colors_lateral(1, :))
hold on
plot3(noo2(fs:end),noo3(fs:end),noo1(fs:end),'.','MarkerSize',6,'color', colors_lateral(2, :))

ax = gca;  
ax.LineWidth = 2; 
set(gca, 'TickDir', 'out');

% Add legend, labels, and formatting
%legend('Column 1', 'Column 2','FontSize', 24)
%xlabel('NMP of e_2 (a.u.)', 'FontSize', w)
%ylabel('NMP of i (a.u.)', 'FontSize', w)
%zlabel('NMP of e_1 (a.u.)', 'FontSize', w)
set(gca, 'FontSize', w);
set(gca, 'box', 'off')
% axis square
% legend('Ground-truth','Est.','FontSize', w-2,'location','southeast')
% legend boxoff

[~,lag] = phaseSpaceReconstruction(ch(1:end),[],3);
eRange = [10 300];
ly=lyapunovExponent(ch(fs:end),fs,lag,3,'ExpansionRange',eRange);
%title(['Period-doubling - \lambda = ' num2str(ly)])
xlim([0.0 1.0])
ylim([0.0 1.0])
zlim([0.0 1.0])

text(0.25, 0.9,0.32, ['\lambda = ' num2str(ly, '%.2f')], 'BackgroundColor', 'none', 'EdgeColor', 'none', 'Margin', 5, 'FontSize', w-2,'color', colors_lateral(1, :));
text(0.25, 0.9,0.15, ['\lambda = ' num2str(0, '%.2f')], 'BackgroundColor', 'none', 'EdgeColor', 'none', 'Margin', 5, 'FontSize', w-2,'color', colors_lateral(2, :));

xticks([0,0.25,0.5,0.75,1])
yticks([0,0.25,0.5,0.75,1])
zticks([0,0.25,0.5,0.75,1])
xticklabels({});
zlabel('Normalised EPSP of {e}^1_1 (a.u.)', 'FontSize', w, 'FontWeight','bold');
yticklabels({});
%zticklabels({});

%%%%%  Figure 3F  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h = subplot(2,3,3);
pos = get(h, 'Position');

% Delete the axes, since we'll replace it with two subplots
delete(h);

    % Directories containing the BMS.mat files for different conditions    
    BMSDir = 'C:\Users\aaa210\OneDrive - University of Sussex\Research projects\DCM validation\Different models test\Period Doubling';

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
    ground_truth = [74.802466469706870, 74.802466469706870];

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
set(gca, 'XTickLabel', x_labels_BMS, 'XTick', 1:numel(x_labels_BMS), 'XTickLabel', '', 'XTickLabelMode', 'manual');

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
set(gca, 'XTickLabel', x_labels_lateral, 'XTick', 1:numel(x_labels_lateral), 'YScale', 'log', 'XTickLabel', '', 'XTickLabelMode', 'manual');

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

%%%%%  Figure 2G  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load("3G&H.mat")
load("3g ch.mat")
load("fig3_chaos.mat")

subplot(2,3,4)

plot(ts,no1,'LineWidth',2,'color', colors_lateral(1, :))
hold on
plot(ts, noo1, 'LineWidth', 1, 'color', colors_lateral(2, :))

ax = gca;  
ax.LineWidth = 2; 
set(gca, 'TickDir', 'out');
% Add legend, labels, and formatting
%legend('Column 1', 'Column 2','FontSize', 24)
set(gca, 'FontSize', w);
xlabel('Time (s)', 'FontSize', w, 'FontWeight','bold')
h = ylabel('Normalised EPSP of {e}^1_1 (a.u.)', 'FontSize', w, 'FontWeight','bold');

set(gca, 'box', 'off')

% axis square
%legend('O1','FontSize', 16)
%legend boxoff
xlim([0 0.75])
xticks([0,0.25,0.5,0.75])
yticks([0,0.2,0.4,0.6,0.8,1])
% t = title('Chaos');
% set(t, 'Position', get(t, 'Position') + [0.6 0 0]); % Move left by 1 unit
%%%%%  Figure 2H  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load("3G&H.mat")

subplot(2,3,5)
plot3(no2(fs:end),no3(fs:end),no1(fs:end),'.','MarkerSize',6,'color', colors_lateral(1, :))
hold on
plot3(noo2(fs:end),noo3(fs:end),noo1(fs:end),'.','MarkerSize',6,'color', colors_lateral(2, :))
ax = gca;  
ax.LineWidth = 2; 
set(gca, 'TickDir', 'out');

% Add legend, labels, and formatting
%legend('Column 1', 'Column 2','FontSize', 24)

%zlabel('NMP of e_1 (a.u.)', 'FontSize', w)
set(gca, 'FontSize', w);
set(gca, 'box', 'off')
% axis square

%lyapExp = lyapunovExponent(ch(1:end),fs)

[~,lag] = phaseSpaceReconstruction(ch(1:end),[],3);
eRange = [50 400];
ly=lyapunovExponent(ch(fs:end),fs,lag,3,'ExpansionRange',eRange);
%title(['Chaos - \lambda = ' num2str(ly)])
xlim([0.0 1.0])
ylim([0.0 1.0])
zlim([0.0 1.0])
xticks([0,0.25,0.5,0.75,1])
yticks([0,0.25,0.5,0.75,1])
zticks([0,0.25,0.5,0.75,1])
zlabel('Normalised EPSP of {e}^1_1 (a.u.)', 'FontSize', w, 'FontWeight','bold');
hy = ylabel('Norm. IPSP of {i}^1 (a.u.)', 'FontSize', 0.9*w, 'FontWeight','bold');
set(hy, 'Rotation', -30); % Rotate Y-label by -30 degrees
posy = get(hy, 'Position'); % Get current position


hx = xlabel('Norm. EPSP of e^1_2 (a.u.)', 'FontSize', 0.9*w, 'FontWeight','bold');
set(hx, 'Rotation', 19); % Rotate Z-label by 30 degrees
posx = get(hx, 'Position'); % Get current position
text(0.25, 0.9,0.30, ['\lambda = ' num2str(ly, '%.2f')], 'BackgroundColor', 'none', 'EdgeColor', 'none', 'Margin', 5, 'FontSize', w-2,'color', colors_lateral(1, :));

text(0.25, 0.9,0.15, ['\lambda = ' num2str(0, '%.2f')], 'BackgroundColor', 'none', 'EdgeColor', 'none', 'Margin', 5, 'FontSize', w-2,'color', colors_lateral(2, :));

% Adjust Y-label position
xpos = posy(1)+ 0.38; % Move left (decrease X value)
ypos = posy(2) + 0.59;  % Move up (increase Y value)
set(hy, 'Position', [xpos ypos posy(3)]); % Apply new position

% Adjust X-label position
xposx = posx(1)+ 0.24; % Move left (decrease X value)
yposx = posx(2) + 0.17;  % Move up (increase Y value)
set(hx, 'Position', [xposx yposx posx(3)]); % Apply new position

%%%%%  Figure 3F  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h = subplot(2,3,6);
pos = get(h, 'Position');

% Delete the axes, since we'll replace it with two subplots
delete(h);

    % Directories containing the BMS.mat files for different conditions    
    BMSDir = 'C:\Users\aaa210\OneDrive - University of Sussex\Research projects\DCM validation\Different models test\Chaos';

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

% Define the gap between subplots
% gap_fraction = 0.1;  % Fraction of the tile's width to use as gap (adjust as desired)
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
ax.XAxis.FontWeight = 'bold'; % Set x-axis tick labels to bold
ax.XAxis.FontSize = w; % Set x-axis tick labels font size to w
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
% ylim([log10(0.001), log10(ground_truth(1) * 1.05)]);

set(ax3b, 'FontSize', w);
ylabel(ax3b, 'Lateral Connection (log scale)', 'FontSize', w, 'FontWeight','bold'); % Increased y-label font size
ax = ax3b;  
ax.LineWidth = 2; 
ax.XAxis.FontWeight = 'bold'; % Set x-axis tick labels to bold
ax.XAxis.FontSize = w; % Set x-axis tick labels font size to w
set(ax3b, 'TickDir', 'out');

set(ax3b, 'box', 'off');
