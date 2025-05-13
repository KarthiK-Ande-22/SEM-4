% Part B: Probability of error vs Eb/N0 comparison for QAM, FSK
% Verifying simulation results with analytical formulas

clear all,close all,clc;

% Simulation parameters
num_bits = 100000;        % Number of bits to transmit
M = 16;                   % Modulation order (16-QAM and 16-FSK)
k = log2(M);              % Number of bits per symbol
num_symbols = num_bits/k; % Number of symbols

% Eb/N0 values in dB
EbN0dB = 0:2:20;
EbN0 = 10.^(EbN0dB/10);

% Initialize error counters
ber_qam = zeros(1, length(EbN0));
ber_fsk = zeros(1, length(EbN0));

% 16-QAM Implementation

% Create 16-QAM constellation (4x4 square constellation)
qam_real = [-3 -1 1 3];
qam_imag = [-3 -1 1 3];
[X, Y] = meshgrid(qam_real, qam_imag);
qam_const = (X(:) + 1i*Y(:))/sqrt(10); % Normalize for average energy = 1

% Generate random symbols
bits = randi([0 1], num_bits, 1);
symbols_dec = bi2de(reshape(bits, k, num_symbols).', 'left-msb');
qam_symbols = qam_const(symbols_dec + 1);

% Simulation for BER calculation
for n = 1:length(EbN0)
    % Calculate noise variance
    N0 = 1/(EbN0(n)*k);
    sigma = sqrt(N0/2);
    
    % Add noise
    noise = sigma * (randn(size(qam_symbols)) + 1i*randn(size(qam_symbols)));
    received = qam_symbols + noise;
    
    % MAP detection (for AWGN, it's minimum distance detection)
    [~, detected_indices] = min(abs(repmat(received, 1, M) - repmat(qam_const.', length(received), 1)), [], 2);
    detected_symbols = detected_indices - 1;
    
    % Convert back to bits
    detected_bits = reshape(de2bi(detected_symbols, k, 'left-msb').', [], 1);
    
    % Count bit errors
    ber_qam(n) = sum(bits ~= detected_bits) / num_bits;
end

% 16-FSK Implementation

% Generate orthogonal FSK basis functions (represented as unit vectors)
fsk_basis = eye(M);

% Generate random symbols
fsk_symbols_dec = symbols_dec; % Use the same symbol sequence for fair comparison
fsk_symbols = fsk_basis(fsk_symbols_dec + 1, :);

% Simulation for BER calculation
for n = 1:length(EbN0)
    % Calculate noise variance
    N0 = 1/(EbN0(n)*k);
    sigma = sqrt(N0/2);
    
    % Add noise
    noise = sigma * randn(size(fsk_symbols));
    received = fsk_symbols + noise;
    
    % MAP detection (correlation receiver for orthogonal FSK)
    [~, detected_indices] = max(received * fsk_basis', [], 2);
    detected_symbols = detected_indices - 1;
    
    % Convert back to bits
    detected_bits = reshape(de2bi(detected_symbols, k, 'left-msb').', [], 1);
    
    % Count bit errors
    ber_fsk(n) = sum(bits ~= detected_bits) / num_bits;
end

% Calculate Theoretical BER

% Theoretical probability of error for 16-QAM (from the second formula in your image)
% Pe ≈ 3Q(√(4Eb/5N0))
Pe_qam_theory = 3 * qfunc(sqrt(4*EbN0/5)) / 4;  % Division by 4 for BER conversion from SER

% Theoretical probability of error for 16-FSK (from the first formula in your image)
% Pe = (M-1)Q(√(Eb*log2(M)/N0))
Pe_fsk_theory = (M-1) .* qfunc(sqrt(EbN0 * log(M)/ log(2))) ;  % Converted to BER

% Plot Probability of Error vs Eb/N0

figure('Name', 'Probability of Error vs Eb/N0');
semilogy(EbN0dB, ber_qam, 'bo-', 'LineWidth', 2, 'DisplayName', '16-QAM Simulation');
hold on;
semilogy(EbN0dB, Pe_qam_theory, 'b--', 'LineWidth', 2, 'DisplayName', '16-QAM Theory');
semilogy(EbN0dB, ber_fsk, 'ro-', 'LineWidth', 2, 'DisplayName', '16-FSK Simulation');
semilogy(EbN0dB, Pe_fsk_theory, 'r--', 'LineWidth', 2, 'DisplayName', '16-FSK Theory');
grid on;
xlabel('Eb/N0 (dB)');
ylabel('Probability of Error');
title('16-QAM vs 16-FSK Performance Comparison over AWGN Channel');
legend('Location', 'southwest');
xlim([min(EbN0dB) max(EbN0dB)]);
ylim([10^-6 1]);

% Helper function for Q-function
function y = qfunc(x)
    y = 0.5 * erfc(x/sqrt(2));
end