function plotBitErrorProbability()
    EbN0_dB = 0:0.1:10;
    EbN0_linear = 10.^(EbN0_dB/10);
    Pe = zeros(size(EbN0_linear));
    for i = 1:length(EbN0_linear)
        Pe(i) = qfunc(sqrt(4*EbN0_linear(i)/5));
    end
    figure;
    semilogy(EbN0_dB, Pe,'r', 'LineWidth', 2);
    grid on;
    xlabel('E_b/N_0 (dB)');
    ylabel('Bit Error Probability');
    title('Bit Error Probability for Gray-coded 4-PAM');
    target_Pe = 1e-2;
    [~, idx] = min(abs(Pe - target_Pe));
    EbN0_target = EbN0_dB(idx);
    hold on;
    plot(EbN0_target, target_Pe, 'bo', 'MarkerSize', 10);
    text(EbN0_target+0.2, target_Pe, ['(' num2str(EbN0_target, '%.2f') ' dB, 10^{-2})']);
    hold off;
    fprintf('The value of Eb/N0 corresponding to a bit error probability of 10^-2 is %.2f dB\n', EbN0_target);
end
