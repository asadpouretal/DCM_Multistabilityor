function plot_free_energy(F_tracker)
    figure;
    plot(F_tracker.F, 'k', 'LineWidth', 2); hold on
    plot(F_tracker.L, '--');
    legend(['Total F', arrayfun(@(x) ['L(' num2str(x) ')'], 1:9, 'UniformOutput', false)])
    xlabel('EM Iteration')
    ylabel('Value')
    title('Progression of Variational Free Energy and Its Components')
    grid on
end
