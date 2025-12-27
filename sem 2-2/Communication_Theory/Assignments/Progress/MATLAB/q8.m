function [t, m, c] = generate_signals(fm, fc, Am, Ac, duration, fs)
    t = 0:1/fs:duration;
    m = Am * sawtooth(2 * pi * fm * t, 0.5); % Triangular message signal
    c = Ac * cos(2 * pi * fc * t);          % Sinusoidal carrier signal

    figure;
    subplot(3,1,1);
    plot(t, m, 'b');
    title('Message Signal (Triangular)');
    xlabel('Time (s)'); ylabel('Amplitude'); grid on;

    subplot(3,1,2);
    plot(t, c, 'r');
    title('Carrier Signal (Cosine)');
    xlabel('Time (s)'); ylabel('Amplitude'); grid on;
end

function modulated = am_modulate(m, c, mu)
    modulated = (1 + mu * m) .* c;  % AM modulation

    subplot(3,1,3);
    plot(modulated, 'g');
    title(['AM Modulated Signal (\mu = ', num2str(mu), ')']);
    xlabel('Time (s)'); ylabel('Amplitude'); grid on;
end

function demodulated = envelope_detector(modulated, fs)
    rectified = abs(modulated); % Full-wave rectification
    demodulated = lowpass(rectified, 2 * 500, fs); % Low-pass filtering with cutoff at 2*fm
end

function compare_demodulation(m, c, fs)
    mu_values = [0.5, 1, 1.2];
    figure; hold on;

    for i = 1:length(mu_values)
        mod_signal = (1 + mu_values(i) * m) .* c;
        recovered = envelope_detector(mod_signal, fs);
        plot(recovered, 'DisplayName', ['\mu = ', num2str(mu_values(i))]);
    end

    plot(m, 'k', 'LineWidth', 1.5, 'DisplayName', 'Original Message');
    legend; title('Recovered Message Signals for Different \mu');
    xlabel('Time (s)'); ylabel('Amplitude'); grid on;
end

function plot_spectrums(m, modulated, demodulated, fs)
    N = length(m);
    f = (-N/2:N/2-1) * (fs/N); 

    M_f = abs(fftshift(fft(m, N)));
    AM_f = abs(fftshift(fft(modulated, N)));
    Rec_f = abs(fftshift(fft(demodulated, N)));

    figure;
    subplot(3,1,1);
    plot(f/1e3, M_f); title('Message Spectrum');
    xlabel('Frequency (kHz)'); ylabel('Magnitude'); grid on;

    subplot(3,1,2);
    plot(f/1e3, AM_f); title('AM Signal Spectrum');
    xlabel('Frequency (kHz)'); ylabel('Magnitude'); grid on;

    subplot(3,1,3);
    plot(f/1e3, Rec_f); title('Recovered Signal Spectrum');
    xlabel('Frequency (kHz)'); ylabel('Magnitude'); grid on;
end

fm = 500; fc = 15000; 
Am = 1; Ac = 10; 
duration = 0.02; fs = 10 * fc;

[t, m, c] = generate_signals(fm, fc, Am, Ac, duration, fs);
mu = 1; 
modulated = am_modulate(m, c, mu);
demodulated = envelope_detector(modulated, fs);
compare_demodulation(m, c, fs);
plot_spectrums(m, modulated, demodulated, fs);
