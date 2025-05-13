% Parameters
A = 1;
sigma = 1;
N = 1e6; 
pi0 = 0.6; 
pi1 = 0.4; 

bits = rand(1, N) > pi0;  

s = 2*bits - 1; 

n = sigma * randn(1, N);
r = s + n;

ml_decision = r >= 0;
ml_error = mean(ml_decision ~= bits);

map_thresh = (sigma^2 / (2*A)) * log(pi0 / pi1);
map_decision = r >= map_thresh;
map_error = mean(map_decision ~= bits);

fprintf('ML Error Rate: %.4f\n', ml_error);
fprintf('MAP Error Rate: %.4f\n', map_error);
fprintf('MAP Threshold: %.4f\n', map_thresh);

% Plot histogram
figure;
histogram(r(bits==0), 100, 'Normalization', 'pdf', 'FaceColor', 'b', 'FaceAlpha', 0.5); hold on;
histogram(r(bits==1), 100, 'Normalization', 'pdf', 'FaceColor', 'r', 'FaceAlpha', 0.5);
xline(0, '--k', 'ML Threshold');
xline(map_thresh, '--g', 'MAP Threshold');
xlabel('Received signal r');
ylabel('Probability Density');
title('Received Signal Histogram with Decision Boundaries');
legend('s_0 = -A','s_1 = +A','ML','MAP');
grid on;
