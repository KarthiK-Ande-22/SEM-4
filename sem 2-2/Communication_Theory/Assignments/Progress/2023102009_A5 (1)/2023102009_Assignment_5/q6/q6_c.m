% Parameters
N = 6000;                   % Number of symbols (4-PAM symbols)
Eb = 1;                     % Energy per bit
M = 4;                      % 4-PAM modulation
k = log2(M);                % 2 bits per symbol
SNR_dB = 6;                 % SNR in dB (example value)
SNR = 10^(SNR_dB/10);       % Linear SNR
sigma2 = Eb / SNR;          % Noise variance
sigma = sqrt(sigma2);       % Noise standard deviation

% 4-PAM Symbol Mapping (±1, ±3)
% Map pairs of bits to 4-PAM symbols
bits = randi([0 1], N * k, 1); % Generate random bits (6000 symbols = 12000 bits)
symbols = 2*bits(1:2:end) - 1; % First bit to ±1
symbols = symbols + 2 * (2*bits(2:2:end) - 1); % Second bit to ±3

% Add Gaussian noise to the transmitted symbols
real_noise = sigma * randn(N, 1);  % Add Gaussian noise to real part
imag_noise = sigma * randn(N, 1); % Add Gaussian noise to imaginary part

% Combine real and imaginary noise
received = symbols + real_noise + 1i * imag_noise;  % Received signal with real and imaginary noise

% --- Plot 1: Received Signal (All in Blue) ---
figure;
scatter(real(received), imag(received), 'b.')
title('Received 4-PAM Symbols (with Noise)');
xlabel('Real Part');
ylabel('Imaginary Part');
grid on;

% --- Decision Rule to Estimate Symbols ---
% Decision boundaries for 4-PAM symbols: [-3, -1, 1, 3]
decision_boundaries = [-2, 0, 2];  % Decision boundaries for real values

% Classify the received symbols into the nearest symbol based on the thresholds
received_symbols = zeros(N, 1);

% Decision rule for mapping the received symbols to the nearest 4-PAM symbol
for i = 1:N
    if real(received(i)) < -2
        received_symbols(i) = -3;
    elseif real(received(i)) < 0
        received_symbols(i) = -1;
    elseif real(received(i)) < 2
        received_symbols(i) = 1;
    else
        received_symbols(i) = 3;
    end
end

% --- Plot 2: Received Symbols Mapped to 4-PAM Symbols ---
figure;
scatter(real(received(received_symbols == -3)), imag(received(received_symbols == -3)), 'ro', 'DisplayName', '-3');
hold on;
scatter(real(received(received_symbols == -1)), imag(received(received_symbols == -1)), 'go', 'DisplayName', '-1');
scatter(real(received(received_symbols == 1)), imag(received(received_symbols == 1)), 'bo', 'DisplayName', '1');
scatter(real(received(received_symbols == 3)), imag(received(received_symbols == 3)), 'mo', 'DisplayName', '3');
title('Received 4-PAM Symbols (Mapped to Nearest Symbols)');
xlabel('Real Part');
ylabel('Imaginary Part');
grid on;
legend;
hold off;

% --- Decision Boundaries (Vertical Lines) ---
% Plot decision boundaries for real part
x_decision_boundaries = [-2, 0, 2];  % Decision boundaries for real parts (±2, 0)

% Plot the decision boundaries
figure;
scatter(real(received), imag(received), 'b.')
hold on;

% Vertical decision boundary lines for real part
plot([x_decision_boundaries(1) x_decision_boundaries(1)], ylim, 'r--', 'LineWidth', 2);
plot([x_decision_boundaries(2) x_decision_boundaries(2)], ylim, 'r--', 'LineWidth', 2);
plot([x_decision_boundaries(3) x_decision_boundaries(3)], ylim, 'r--', 'LineWidth', 2);

% Set plot labels and title
title('Real vs Imaginary Parts of Received Symbols with Decision Boundaries');
xlabel('Real Part');
ylabel('Imaginary Part');
grid on;
legend('Received Symbols', 'Decision Boundaries');
hold off;

% --- Compute Bit Error Rate (BER) ---
% Map the received symbols back to the original bits
bits_est = zeros(2*N, 1);  % Estimated bits
bits_est(1:2:end) = (received_symbols == 1) | (received_symbols == 3);  % First bit (1 if decision is 1 or 3)
bits_est(2:2:end) = (received_symbols == 3) | (received_symbols == -3); % Second bit (1 if decision is 3 or -3)

% Compute Bit Error Rate (BER)
bit_errors = sum(bits ~= bits_est); % Compare transmitted and estimated bits
BER = bit_errors / (2*N);           % Bit error rate (normalized by total bits)

% Display Bit Error Rate (BER)
fprintf('Bit Error Rate (BER) = %.5f\n', BER);
