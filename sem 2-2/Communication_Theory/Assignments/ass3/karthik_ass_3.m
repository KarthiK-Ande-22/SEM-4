clc;
clear;
close all;



sampling_frequency=50000;
time=0:1/sampling_frequency:0.1;

% part-b

Modulation_index=5;
del_f_max=50;
fm=del_f_max/Modulation_index;
fc=1000;
theta=(Modulation_index)*sin(2*pi*fm*time);
FM_Signal=cos(2*pi*fc*time+theta);

%given Ac,Am=1, => kf=50;

message_signal=cos(2*pi*fm*time);

subplot(2,1,1)
plot(time,message_signal, 'b','LineWidth', 1.5);
title("Message signal");

subplot(2,1,2)
plot(time,FM_Signal, 'r','LineWidth', 1.5);
title("Frequency modulated signal");

% part-c

N = length(FM_Signal);     
U = fft(FM_Signal);        
f = (-N/2:N/2-1) * (sampling_frequency / N); 

% Plot spectrum
figure;
plot(f, abs(fftshift(U)), 'r', 'LineWidth', 1.4); 
xlabel('Frequency');
ylabel('Magnitude');
title('Spectrum of FM signal u(t) ');
grid on;
xlim([-1500 1500]); 

%part-d

% we can do demodulation by passing through a discriminator /differentiator
%and finding envelope which is m(t)
%in order to demodulate we would like to differentiate and latch
%on the envelop

diff_FM_signal= gradient(FM_Signal,1/sampling_frequency);

[peaks, locs] = findpeaks(abs(diff_FM_signal), time); 
env_interp = interp1(locs, peaks, time,"linear","extrap"); 
env_interp=(env_interp-mean(env_interp))/(2*pi);

% Plots
figure;
subplot(2,1,1)
plot(time, env_interp, 'b', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Amplitude');
title("Demodulated message signal");

subplot(2,1,2)
plot(time,message_signal,'r','LineWidth',1.5);
xlabel('Time (s)');
ylabel('Amplitude');
title("Original message signal");

grid on;