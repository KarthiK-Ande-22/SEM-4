rng(42)
% Common parameters
N = 1e6;
A = 1;
sigma2 = 1;
sigma = sqrt(sigma2);
pi0 = 0.6;
pi1 = 0.4;

% For MAP: generate bits based on prior
bits = rand(1, N) > pi0;        % 0 with prob pi0, 1 with prob pi1
s = 2 * bits - 1;
r = s + sigma * randn(1, N);

% MAP Decision
threshold_map = (sigma2 / (2*A)) * log(pi0 / pi1);
bits_map_hat = r > threshold_map;
error_map = mean(bits_map_hat ~= bits);

% ML Decision (assumes equal priors, threshold at 0)
bits_ml_hat = r > 0;
error_ml = mean(bits_ml_hat ~= bits);

fprintf('MAP error rate = %.5f\n', error_map);
fprintf('ML  error rate = %.5f\n', error_ml);

