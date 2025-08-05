% clear all

% cd("C:\New folder")
load("non decision data.mat")


w=26;
fs=1000;
no1_o1 = zeros(1, size(h, 1));
no1_o2 = zeros(1, size(h1, 1));
g = [h h1];  % Concatenate along the first dimension

for i = 1:size(h, 2)
    min_g = min(g);
    max_g = max(g);

    no_o1(i) = (h(1, i) - min_g) / (max_g - min_g);
    no_o2(i) = (h1(1, i) - min_g) / (max_g - min_g);
end

darkGreen = [  0, 158, 115]/255;    % or [0, 0.5, 0]
brightGreen = [50, 205, 50] / 255;

t = linspace(0, 4, 4*fs);

plot(t-1,no_o1,'LineWidth',3,'color',darkGreen)
hold on
plot(t-1,no_o2,'LineWidth',3,'color',brightGreen)
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

set(gca, 'box', 'off')
%set(gca, 'XColor', 'none');
%set(gca, 'YColor', 'none');

%axis square
xlim([-1 3])
%legend('e_1 in column 1','e_1 in column 2','FontSize', 22)
%legend boxoff

xticks([0 3])
ax = gca;  
ax.LineWidth = 2; 

yticks(0:0.2:1)

legend('e_1^1','e_1^2')
legend boxoff
set(gca, 'FontSize', w);
xlabel('Time from stimulus onset (s)', 'FontSize', w);
ylabel('Normalised EPSP of e_1 (a.u.)', 'FontSize', w)
