function set_BMS_figure()
%set_BMS_figure sets font, linewidth, ... for Bayesian model selection
%figures
[title_fontweight, lable_fontsize, lable_fontweight, legend_fontsize, num_of_source_in_figure, column_title_position, show_xlabel, scale_factor] = mainfigure_variables();
increase_additive = 0;
axis_fontsize = lable_fontsize;
title_fontsize = lable_fontsize + 2 + increase_additive;
label_fontsize = lable_fontsize + increase_additive;
for subplot_num = 1 : 2
    ax = subplot(2,1,subplot_num);
    box off;
    grid off;
    ax.LineWidth = 2;
    xax = ax.XAxis;
    set(xax,'TickDirection','none', 'fontsize', axis_fontsize, 'FontWeight','bold');
    
    yax = ax.YAxis; % xax = get(ax,'XAxis');
    set(yax,'TickDirection','in', 'fontsize', axis_fontsize, 'FontWeight','bold');
    
    title(ax, 'Bayesian Model Selection: RFX', 'FontSize', title_fontsize, 'FontWeight',title_fontweight);
    xlabel(ax, 'Models', 'FontSize',label_fontsize, 'FontWeight','bold');
    switch subplot_num
        case 1
            ylabel(ax, 'Model Expected Probability', 'FontSize',label_fontsize, 'FontWeight','bold');
        case 2
            ylabel(ax, 'Model Exceedance Probability', 'FontSize',label_fontsize, 'FontWeight','bold');
    end
end
end