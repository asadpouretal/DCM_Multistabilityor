
% Create the figure
clear all
close all
% Get the user directory (C:\Users\Amin)
userDir = char(java.lang.System.getProperty('user.home'));

% Construct the Desktop path
desktopPath = fullfile(userDir, 'Desktop', 'figures', 'FIG2');

% Add the Desktop path to MATLAB's search path
addpath(desktopPath);
w=20;

% Create combined figure
figure('Units', 'normalized', 'Position', [0, 0, 1, 0.70]);

% First plot in the first tile

%%%%%  Figure 1D  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load("2D.mat")

subplot(1,3,1);

plot(t-1,no_o1,'LineWidth',3,'color',[0, 0.6196, 0.4510])
hold on
plot(t-1,no_o2,'LineWidth',3,'color',[0, 0.6196, 0.4510, 0.5])
hold on
% Define the x-axis span for the shaded area
x_start = 0;
x_end = 2;

% Define the y-axis limits (use the current axis limits)
y_limits = ylim;

% Define the coordinates for the shaded area
x_coords = [x_start x_end x_end x_start];
y_coords = [y_limits(1) y_limits(1) y_limits(2) y_limits(2)];

% Create a shaded area using patch
patch(x_coords, y_coords, [0.5 0.5 0.5], 'FaceAlpha', 0.3, 'EdgeColor', 'none');
hold on

% Draw a dashed line at y = 0.6
y_value = 0.6;
x_limits = xlim; % Get the current x-axis limits

% Draw a dashed line that spans the entire x-axis range
%line(x_limits, [y_value y_value], 'LineStyle', '--', 'Color', 'k', 'LineWidth', 2);
set(gca, 'TickDir', 'out');
% Add legend, labels, and formatting
%legend('Column 1', 'Column 2','FontSize', 24)
%xlabel('Time from stimulus onset (s)', 'FontSize', 26)
set(gca, 'FontSize', w);
ylabel('Normalised EPSP (a.u.)', 'FontSize', w, 'FontWeight','bold')

set(gca, 'box', 'off')
%set(gca, 'XColor', 'none');
%set(gca, 'YColor', 'none');

%axis square
xlim([-1 3])
%legend('e_1 in column 1','e_1 in column 2','FontSize', 22)
%legend boxoff

xticks([0 3])

n = 5;
h = o1_e1(n, :);
h1 = o2_e1(n, :);
no1_o1 = zeros(1, size(h, 1));
no1_o2 = zeros(1, size(h1, 1));
g = [h h1];  % Concatenate along the first dimension

for i = 1:size(h, 2)
    min_g = min(g);
    max_g = max(g);

    no1_o1(i) = (h(1, i) - min_g) / (max_g - min_g);
    no1_o2(i) = (h1(1, i) - min_g) / (max_g - min_g);
end


t = linspace(0, 4, 4*fs);
r1=nan*linspace(0, 4, 4*fs);

hold on
plot(t-1, no1_o1, 'LineWidth', 3, 'LineStyle', '--', 'Color', [0, 0.6196, 0.4510]);
hold on
plot(t-1, no1_o2, 'LineWidth', 3, 'LineStyle', '--', 'Color', [0, 0.6196, 0.4510, 0.5]);
hold on
plot(t-1, r1, 'LineWidth', 3, 'LineStyle', '-', 'Color', [0.5 0.5 0.5]);
hold on
plot(t-1, r1, 'LineWidth', 3, 'LineStyle', '--', 'Color', [0.5 0.5 0.5]);

yticks([0, 0.2, 0.4, 0.6, 0.8, 1]);
legend('{e}^1_1','{e}^2_1' ,'FontSize', w-2,'location','northeast');  % light gray background
legend boxoff;

ax = gca;  
ax.LineWidth = 2; 

% Second plot in the second tile
subplot(1,3,2);
load("2E.mat")


for i = 1
plot(t,no1_o1,'LineWidth',3, 'Color', colors(i, :))
hold on
plot(t,no2_o1,'LineWidth',3,'Color', colors(i+1, :))
hold on
plot(t,no3_o1,'LineWidth',3,'Color', colors(i+2, :))
hold on
plot(t,no4_o1,'LineWidth',3,'Color', colors(i+3, :))
hold on
%plot(t,no5_o1,'LineWidth',3,'Color', colors(i+4, :))
%hold on
plot(t,no1_o2,'LineWidth',3,'Color', colors(i, :))
hold on
plot(t,no2_o2,'LineWidth',3,'Color', colors(i+1, :))
hold on
plot(t,no3_o2,'LineWidth',3,'Color', colors(i+2, :))
hold on
plot(t,no4_o2,'LineWidth',3,'Color', colors(i+3, :))
hold on
%plot(t,no5_o2,'LineWidth',3,'Color', colors(i+4, :))
hold on
y_value = 0.6;
x_limits = xlim; % Get the current x-axis limits

% Draw a dashed line that spans the entire x-axis range
end
line(x_limits, [y_value y_value], 'LineStyle', '--', 'Color', 'k', 'LineWidth', 2);
yticks([0, 0.2, 0.4, 0.6, 0.8, 1]);
set(gca, 'FontSize', w);
h = xlabel('Time from stimulus onset (s)', 'FontSize', w, 'FontWeight','bold');

% Adjust the position of the x-label
currentPos = get(h, 'Position');  % Get current position [x, y, z]
newXPos = currentPos(1) - 2.6;      % Move the label to the left by decreasing the x-value
set(h, 'Position', [newXPos, currentPos(2) - 0.01, currentPos(3)]);

%ylabel('NEPSP', 'FontSize', 26)

set(gca, 'TickDir', 'out');
% Add legend, labels, and formatting
%legend('Column 1', 'Column 2','FontSize', 24)
%set(gca, 'FontSize', 20);
set(gca, 'box', 'off')
%set(gca, 'XColor', 'none');
%set(gca, 'YColor', 'none');
%axis square


xticks([0 3])

hold on
% Define the x-axis span for the shaded area
x_start = 0;
x_end = 2;

% Define the y-axis limits (use the current axis limits)
y_limits = ylim;

% Define the coordinates for the shaded area
x_coords = [x_start x_end x_end x_start];
y_coords = [y_limits(1) y_limits(1) y_limits(2) y_limits(2)];

% Create a shaded area using patch
patch(x_coords, y_coords, [0.5 0.5 0.5], 'FaceAlpha', 0.3, 'EdgeColor', 'none');
hold on

% Draw a dashed line at y = 0.6
y_value = 0.6;
x_limits = xlim; % Get the current x-axis limits
legend('\epsilon = 0%','\epsilon = 11%','\epsilon = 20%','\epsilon = 27%','FontSize', w-2,'location','northwest')
legend boxoff

xlim([-1 3])
ax = gca;  
ax.LineWidth = 2; 


%set(gca, 'ytick', [])
text(1.13, 0.62, 'Threshold', 'BackgroundColor', 'none', 'EdgeColor', 'none', 'Margin', 5, 'FontSize',w-2);



for i=1:length(a_values)
I(i)=(a_values(i)-0.1)/(a_values(i)+0.1);
end

% Third tile: Create two subplots within the third tile with more space between them
yticklabels({});

% Get the position of the third subplot
h = subplot(1,3,3);
load("2F.mat")

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
plot(ax3a,I*100,acc,'o-','LineWidth',2,'MarkerSize',6,'color','k')
%plot(I*100,acc,'o-','LineWidth',2,'MarkerSize',6,'color','k')
%xlabel(ax3a,'Evidence quality \epsilon (%)', 'FontSize', 20)
set(ax3a, 'FontSize', w);
ylabel(ax3a,"Acc. (%)", 'FontSize', 0.85*w, 'FontWeight','bold')
ax = ax3a;  
ax.LineWidth = 2; 
set(ax3a, 'TickDir', 'out');
set(ax3a, 'box', 'off')
%set(ax3a, 'XColor', 'none');
set(ax3a,'XTickLabel', []);

for i=1:length(a_values)
%if (length(error_trial_indices{i})<10)
%avg_error_rts(i)=nan;  
%end
g=[avg_decision_rts avg_error_rts];    
no_avg_decision_rts(i)=(avg_decision_rts(i)-nanmin(g))/(nanmax(g)-nanmin(g));
no_avg_error_rts(i)=(avg_error_rts(i)-nanmin(g))/(nanmax(g)-nanmin(g));
end
no_avg_error_rts(1,6:7)=nan;
%set(ax3b, 'XColor', 'none');
%nexttile
plot(ax3b,I*100,no_avg_decision_rts,'o-','LineWidth',2,'MarkerSize',6,'color','k')
hold on
plot(ax3b,I*100,no_avg_error_rts,'o--','LineWidth',2,'MarkerSize',6,'color','k')
    % Create invisible dummy plots for the legend
    h1 = plot(nan, nan, 'k-', 'LineWidth', 2);  % Solid line for correct
    h2 = plot(nan, nan, 'k--', 'LineWidth', 2); % Dashed line for error
    % Assign legend to the dummy plots
    legend(ax3b, [h1, h2], {'Corr.', 'Err.'}, 'Location', 'northeast', 'FontSize', w-2 , 'TextColor', 'k');
    legend boxoff;
    hold off;    

xlabel(ax3b,'\epsilon (%)', 'FontSize', w, 'FontWeight','bold')
set(ax3b, 'FontSize', w);
ylabel(ax3b,'Normalised decision time (a.u.)', 'FontSize', 0.85*w, 'FontWeight','bold')
legend boxoff
ax = ax3b;  
ax.LineWidth = 2; 
set(ax3b, 'TickDir', 'out');
set(ax3b, 'box', 'off')
%plot(output1_EEG(37,:))
%hold on
%plot(output2_EEG(37,:))


%ylim(ax3a, [-10, 10]);  % Limit y-axis for better visualization

% Create the second subplot in the bottom half
%ax3b = axes('Position', pos2);
%plot(ax3b, x, exp(-x));
%title(ax3b, 'Plot 3b: exp(-x)');

% Optional: Link the x-axes of the subplots if desired
%linkaxes([ax3a, ax3b], 'x');

