function plotLogSTFT(signal, fs)
    % signal: Input signal
    % fs: Sampling frequency

    % Parameters for STFT
    window = hamming(256);  % Window function (can be adjusted)
    noverlap = 128;         % Overlap between windows (50% overlap)
    nfft = 1024;            % Number of FFT points

    % Compute STFT
    [S,F,T] = spectrogram(signal, window, noverlap, nfft, fs);

    % Plot STFT
    figure;
    imagesc(T, F, 20*log10(abs(S))); % Plot magnitude of STFT in dB
    axis xy;  % Flip the Y-axis so frequency increases upwards
    xlabel('Time (s)');
    ylabel('Frequency (Hz)');
    title('STFT with Logarithmic Frequency Axis');
    colorbar;

    % Set the Y-axis to logarithmic scale
    set(gca, 'YScale', 'log');

    % Adjust the ticks on the Y-axis to show logarithmic scale correctly
    yticks = [10 20 50 100 200 500 1000 2000 5000 10000]; % Example frequencies
    yticklabels = {'10','20','50','100','200','500','1k','2k','5k','10k'}; 
    set(gca, 'YTick', yticks, 'YTickLabel', yticklabels);

end
