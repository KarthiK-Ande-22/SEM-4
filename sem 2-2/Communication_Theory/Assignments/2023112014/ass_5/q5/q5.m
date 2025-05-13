% Parameters
E = 1;
N = 100;  % Number of samples
sigmas = [0.1, 0.3, 0.5];

% Loop over different sigma values
for idx = 1:length(sigmas)
    sigma = sigmas(idx);
    n0 = sigma * randn(N, 1);
    n1 = sigma * randn(N, 1);
    
    % Symbol 1: (sqrt(E) + n0, n1)
    r1_0 = sqrt(E) + n0;
    r1_1 = n1;
    
    % Symbol 2: (n0, sqrt(E) + n1)
    r2_0 = n0;
    r2_1 = sqrt(E) + n1;
    
    % Plotting
    figure;
    scatter(r1_0, r1_1, 50, 'b', 'o'); hold on;
    scatter(r2_0, r2_1, 50, 'r', '*');
    xlabel('r_0'); ylabel('r_1');
    title(['Binary Communication: \sigma = ', num2str(sigma)]);
    legend('Symbol 1', 'Symbol 2');
    axis equal; grid on;
end
