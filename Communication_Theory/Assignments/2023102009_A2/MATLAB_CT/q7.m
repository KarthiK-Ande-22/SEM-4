function modulated = multiplier_modulation(m, c)
    modulated = m .* c; % Multiply message with carrier

    subplot(2,2,2);
    plot(modulated, 'r');
    title('DSB-SC Modulated Signal (Multiplier)');
    xlabel('Time (s)'); ylabel('Amplitude');
    grid on;
end

function modulated = switching_modulation(m, c)
    square_wave = sign(c);
    modulated = m .* square_wave; 

    subplot(2,2,3);
    plot(modulated, 'g');
    title('DSB-SC Modulated Signal (Switching)');
    xlabel('Time (s)'); ylabel('Amplitude');
    grid on;
end

function demod = demod_switch(modulated, c, fs, fm)
    square_wave = sign(c); 
    demod = modulated .* square_wave; 
    fc_lp = 4 * fm; 
    demod = lowpass(demod, fc_lp, fs);

    subplot(1,2,2);
    plot(demod, 'k');
    title('demod Signal');
    xlabel('Time (s)'); ylabel('Amplitude');
    grid on;
end


function phse_effects(modulated, fc, fs, t, fm)
    theta1 = pi/3;
    df = 5;

    c1 = cos(2 * pi * fc * t + theta1);
    demod1 = modulated .* c1;
    demod1 = lowpass(demod1, fm, fs);

    c2 = cos(2 * pi * (fc + df) * t);
    demod2 = modulated .* c2;
    demod2 = lowpass(demod2, fm, fs);

    c3 = cos(2 * pi * (fc + df) * t + theta1);
    demod3 = modulated .* c3;
    demod3 = lowpass(demod3, fm, fs);

    figure;
    subplot(3,1,1);
    plot(demod1, 'b');
    title('Demodulated Signal (Phase Shift π/3)');
    xlabel('Time (s)'); ylabel('Amplitude');

    subplot(3,1,2);
    plot(demod2, 'r');
    title('Demodulated Signal (Frequency Shift 5 Hz)');
    xlabel('Time (s)'); ylabel('Amplitude');

    subplot(3,1,3);
    plot(demod3, 'g');
    title('Demodulated Signal (Freq Shift 5 Hz & Phase Shift π/3)');
    xlabel('Time (s)'); ylabel('Amplitude');
end

function freq_spect(m, modulated, demodulated, fs)
    N = length(m);
    f = (-N/2:N/2-1) * (fs/N); % Frequency axis

    M_f = abs(fftshift(fft(m, N)));
    Modulated_f = abs(fftshift(fft(modulated, N)));
    Demodulated_f = abs(fftshift(fft(demodulated, N)));

    figure;
    subplot(3,1,1);
    plot(f/1e3, M_f);
    title('Frequency Spectrum of Message Signal');
    xlabel('Frequency (kHz)'); ylabel('Magnitude');
    grid on;

    subplot(3,1,2);
    plot(f/1e6, Modulated_f);
    title('Frequency Spectrum of Modulated Signal');
    xlabel('Frequency (MHz)'); ylabel('Magnitude');
    grid on;

    subplot(3,1,3);
    plot(f/1e3, Demodulated_f);
    title('Frequency Spectrum of Demodulated Signal');
    xlabel('Frequency (kHz)'); ylabel('Magnitude');
    grid on;
end




am=1;
ac=1;
fm=10000;
fc=100000000;
ts = 1/(10*fc); 
T = 1e-3;   
t = 0:ts:T;
m=am*sin(2*pi*fm*t);
c=ac*cos(2*pi*fc*t);
fs = 10 * fc;
figure;
subplot(2,2,1);
plot(t, m, 'b');
title('Message Signal m(t)');
xlabel('Time (s)'); ylabel('Amplitude');
grid on;


mod_mult = multiplier_modulation(m, c);
mod_switch = switching_modulation(m, c);
figure;
subplot(1,2,1);
plot(mod_switch, 'g');
    title('DSB-SC Modulated Signal (Switching)');
    xlabel('Time (s)'); ylabel('Amplitude');
    grid on;


demod = demod_switch(mod_switch, c, fs, fm);


phse_effects(mod_mult, fc, fs, t, fm);

freq_spect(m, mod_mult, demod, fs);

