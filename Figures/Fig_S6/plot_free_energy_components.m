function plot_free_energy_components(folder_path)

    % Plot settings
    w = 20; % font size and line width
    files = {
        'F_tracker.mat',    'Lat.', [0, 0, 0];           % black
        'F_tracker_1.mat',  'FB',   [1.0, 0.55, 0];       % dark orange
        'F_tracker_2.mat',  'FC',   [0, 0.5, 0]           % dark green
    };

    figure('Units', 'normalized', 'Position', [0, 0, 0.3, 0.4]); hold on
    all_handles = []; all_labels = {};
    min_y = inf;
    max_iter = 0;

    % Plot curves for each model
    for i = 1:size(files,1)
        fpath = fullfile(folder_path, files{i,1});
        if exist(fpath, 'file')
            data = load(fpath);
            fn = fieldnames(data);
            tracker = data.(fn{1});
            
            F = tracker.F;
            L = tracker.L;
            
            accuracy = L(:,1) + L(:,6) + L(:,7);                % L(1), L(6), L(7)
            complexity = sum(L,2) - accuracy;

            col = files{i,3};

            % Plot and store handle only for F (solid line)
            
            % Define symmetric log transform
            symlog = @(x) sign(x) .* log10(1 + abs(x));
            
            % Apply transformation and assign handles
            h1 = plot(symlog(F), '-', 'Color', col, 'LineWidth', 2);            % F
            plot(symlog(accuracy), ':', 'Color', col, 'LineWidth', 2);          % Accuracy
            plot(symlog(complexity), '-.', 'Color', col, 'LineWidth', 2);       % Complexity
            % 

            all_handles(end+1) = h1;
            all_labels{end+1} = files{i,2}; % Lat., FB, FC
            min_y = min([min_y; F(:); accuracy(:); complexity(:)]);
            max_y = max([F(:); accuracy(:); complexity(:)]);
            max_iter = max(max_iter, length(F));
        end
    end

    % Add dummy grey lines for line-style reference
    gray = [0.5 0.5 0.5];
    hF  = plot(nan, nan, '-',  'Color', gray, 'LineWidth', 2);
    ha  = plot(nan, nan, ':',  'Color', gray, 'LineWidth', 2);
    hc  = plot(nan, nan, '-.', 'Color', gray, 'LineWidth', 2);
    xlim([1, max_iter]);
    % ylim([symlog(min_y), symlog(max_y)]);


    all_handles = [all_handles, hF, ha, hc];
    all_labels  = [all_labels, {'F', 'Accuracy', 'Complexity'}];

    % Apply unified legend
    leg = legend(all_handles, all_labels, 'FontSize', w - 5, 'Location', 'best', 'FontWeight','bold');
    set(leg, 'Box', 'off');

    % Axis settings
    xlabel('EM Iteration', 'FontSize', w, 'FontWeight','bold');
    ylabel('Signed log(1 + |value|)', 'FontSize', w, 'FontWeight','bold');

    ax = gca;
    ax.LineWidth = 2;
    set(gca, 'TickDir', 'out');
    set(gca, 'FontSize', w);
    set(gca, 'box', 'off');
end
