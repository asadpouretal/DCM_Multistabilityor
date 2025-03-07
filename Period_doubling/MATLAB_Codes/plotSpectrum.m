function plotSpectrum(signal, fs)
    % signal: Input signal
    % fs: Sampling frequency

    % Length of the signal
    L = length(signal);
    
    % Compute the FFT of the signal
    Y = fft(signal);
    
    % Compute the two-sided spectrum, then the one-sided spectrum
    P2 = abs(Y / L); % Two-sided spectrum
    P1 = P2(1:L/2+1); % One-sided spectrum
    P1(2:end-1) = 2 * P1(2:end-1); % Double the non-DC components
    
    % Frequency axis
    f = fs * (0:(L/2)) / L;

    % Plot the spectrum with logarithmic frequency scale
    figure;
    plot(f, 20*log10(P1)); % Plot magnitude in dB
    set(gca, 'XScale', 'log'); % Set X-axis to logarithmic scale
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');
    title('Magnitude Spectrum with Logarithmic Frequency Axis');
    grid on;

    % Optionally, set custom ticks for the log-scale X-axis
    xticks = [10 20 50 100 200 500 1000 2000 5000 10000]; % Example frequencies
    xticklabels = {'10','20','50','100','200','500','1k','2k','5k','10k'}; 
    set(gca, 'XTick', xticks, 'XTickLabel', xticklabels);
end
