function plotFreeEnergy_PD_Chaos()

    % Font size and bar colour
    w = 18;
    bar_color = [0 0 0];  % Black
    x_labels = {'Lat', 'FB', 'FC'};

    % Directories
    PD_dir = 'C:\Users\aaa210\OneDrive - University of Sussex\Research projects\DCM validation\Different models test\Period Doubling\BMS';
    Chaos_dir = 'C:\Users\aaa210\OneDrive - University of Sussex\Research projects\DCM validation\Different models test\Chaos\BMS';

    % Load BMS.mat files
    PD_data = load(fullfile(PD_dir, 'BMS.mat'));
    Chaos_data = load(fullfile(Chaos_dir, 'BMS.mat'));

    % Extract Free Energy matrices
    F_PD = PD_data.BMS.DCM.rfx.F;        % [nTrials x nModels]
    F_Chaos = Chaos_data.BMS.DCM.rfx.F;

    % Compute means
    meanF_PD = mean(F_PD, 1);
    meanF_Chaos = mean(F_Chaos, 1);

    % Create figure
    figure('Name', 'Free Energy: PD and Chaos', ...
           'Units', 'normalized', ...
           'Position', [0.2, 0.4, 0.3, 0.5]);

    % -------- Subplot 1: Period Doubling --------
    subplot(1,2,1);
    bar(meanF_PD, 'FaceColor', bar_color);
    % title('Period Doubling', 'FontSize', w);
    ylabel('Mean Free Energy (F)', 'FontSize', w);
    set(gca, 'XTickLabel', x_labels, 'FontSize', w, ...
             'TickDir', 'out', 'LineWidth', 2);
    box off;
    ax = gca;
    ax.XAxis.TickLength = [0 0];

    % -------- Subplot 2: Chaos --------
    subplot(1,2,2);
    bar(meanF_Chaos, 'FaceColor', bar_color);
    % title('Chaos', 'FontSize', w);
    set(gca, 'XTickLabel', x_labels, 'FontSize', w, ...
             'TickDir', 'out', 'LineWidth', 2);
    box off;
    ax = gca;
    ax.XAxis.TickLength = [0 0];

end
