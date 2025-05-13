clear; clc; close all;

% Parameters
N = 1e4;  % Number of symbols
EbN0_dB = [0, 5, 10, 20];  % Eb/N0 values in dB
M = 16;  % Modulation order

% 16-PAM Setup
symbols_16pam = linspace(-15, 15, M);  % Normalized 16-PAM symbols
Eb_pam = mean(symbols_16pam.^2) / log2(M);  % Energy per bit

data_pam = randi([0 M-1], 1, N);
transmitted_symbols_pam = symbols_16pam(data_pam + 1);

% 16-QAM Setup
[x, y] = meshgrid([-3 -1 1 3], [-3 -1 1 3]);  % Square 16-QAM
symbols_16qam = x(:).' + 1i * y(:).';
Eb_qam = mean(abs(symbols_16qam).^2) / log2(M);

data_qam = randi([0 M-1], 1, N);
transmitted_symbols_qam = symbols_16qam(data_qam + 1);

% 16-PAM Constellation Plot
figure('Name', '16-PAM Constellation (3x1)');
for i = 1:length(EbN0_dB)
    EbN0 = 10^(EbN0_dB(i)/10);
    sigma_pam = sqrt(Eb_pam / (2 * EbN0));

    % Add noise
    noise_I = sigma_pam * randn(1, N);
    noise_Q = sigma_pam * randn(1, N);
    received_symbols_pam = transmitted_symbols_pam + noise_I + 1i * noise_Q;

    % MAP Detection (real part only)
    detected_indices_pam = zeros(1, N);
    for j = 1:N
        [~, idx] = min(abs(real(received_symbols_pam(j)) - symbols_16pam));
        detected_indices_pam(j) = idx - 1;
    end

    % Symbol Error Rate
    num_errors_pam = sum(detected_indices_pam ~= data_pam);
    SER_pam = num_errors_pam / N;

    % Plot
    figure(i)
    scatter(real(received_symbols_pam), imag(received_symbols_pam), 10, 'b', 'filled');
    hold on;
    scatter(symbols_16pam, zeros(1, M), 100, 'r', 'x', 'LineWidth', 2);
    grid on;
    axis equal;
    title(sprintf('16-PAM, Eb/N0 = %d dB, SER = %.4f', EbN0_dB(i), SER_pam));
    xlabel('In-Phase'); ylabel('Quadrature');
end

% 16-QAM Constellation Plot
figure('Name', '16-QAM Constellation (3x1)');
for i = 1:length(EbN0_dB)
    EbN0 = 10^(EbN0_dB(i)/10);
    sigma_qam = sqrt(Eb_qam / (2 * EbN0));

    noise = sigma_qam * (randn(1, N) + 1i * randn(1, N));
    received_symbols_qam = transmitted_symbols_qam + noise;

    % MAP Detection
    detected_indices_qam = zeros(1, N);
    for j = 1:N
        [~, idx] = min(abs(received_symbols_qam(j) - symbols_16qam));
        detected_indices_qam(j) = idx - 1;
    end

    % Symbol Error Rate
    num_errors_qam = sum(detected_indices_qam ~= data_qam);
    SER_qam = num_errors_qam / N;

    % Plot
    figure(i+4)
    scatter(real(received_symbols_qam), imag(received_symbols_qam), 10, 'b', 'filled');
    hold on;
    scatter(real(symbols_16qam), imag(symbols_16qam), 100, 'r', 'x', 'LineWidth', 2);
    grid on;
    axis equal;
    title(sprintf('16-QAM, Eb/N0 = %d dB, SER = %.4f', EbN0_dB(i), SER_qam));
    xlabel('In-Phase'); ylabel('Quadrature');
end
