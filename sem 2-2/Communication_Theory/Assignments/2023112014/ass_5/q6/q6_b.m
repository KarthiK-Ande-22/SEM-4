EbN0_dB = 0:0.1:10;
EbN0 = 10.^(EbN0_dB/10);

Pe = erfc(sqrt((4/5) * EbN0));

semilogy(EbN0_dB, Pe, 'LineWidth', 2);
xlabel('Eb/N0 (dB)');
ylabel('Bit Error Probability');
title('Bit Error Probability for Gray-coded 4-PAM');
grid on;

% Find Eb/N0 at Pe ≈ 10^-2
targetPe = 1e-2;
idx = find(Pe < targetPe, 1, 'first');
fprintf('Eb/N0 for Pe ≈ 10^-2 is %.2f dB\n', EbN0_dB(idx));
