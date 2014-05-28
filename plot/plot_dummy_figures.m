x = 50:50:500;
xx = linspace(0,1,10);

y1 = (xx-2).^4;
y2 = 2*y1;
y3 = (xx-3).^4;
y4 = (xx-4).^4;
y5 = (xx-2.5).^4;

%% synthetic data

subplot(2, 3, 1)
hold on
plot(x, y1, 'b-', 'linewidth', 2);
plot(x, y3, 'g-.', 'linewidth', 2);
plot(x, y2, 'r--', 'linewidth', 2);
plot(x, y5, 'k-', 'linewidth', 2);
xlabel('number of samples', 'fontsize', 14);
ylabel('structural hamming distance', 'fontsize', 14);
title('Convergence on Asia network', 'fontsize', 14);
legend('ours', 'BIC', 'MMHC', 'GBN');

subplot(2, 3, 2)
hold on
plot(x, y1, 'b-', 'linewidth', 2);
plot(x, y3, 'g-.', 'linewidth', 2);
plot(x, y2, 'r--', 'linewidth', 2);
plot(x, y5, 'k-', 'linewidth', 2);
xlabel('number of samples', 'fontsize', 14);
ylabel('structural hamming distance', 'fontsize', 14);
title('Convergence on Child network', 'fontsize', 14);
legend('ours', 'BIC', 'MMHC', 'GBN');

subplot(2, 3, 3)
hold on
plot(x, y1, 'b-', 'linewidth', 2);
plot(x, y3, 'g-.', 'linewidth', 2);
plot(x, y2, 'r--', 'linewidth', 2);
plot(x, y5, 'k-', 'linewidth', 2);
xlabel('number of samples', 'fontsize', 14);
ylabel('structural hamming distance', 'fontsize', 14);
title('Convergence on Insurance network', 'fontsize', 14);
legend('ours', 'BIC', 'MMHC', 'GBN');

subplot(2, 3, 4)
hold on
plot(x, fliplr(y1), 'b-', 'linewidth', 2);
plot(x, fliplr(y3), 'g-.', 'linewidth', 2);
plot(x, fliplr(y2), 'r--', 'linewidth', 2);
plot(x, fliplr(y5), 'k-', 'linewidth', 2);
xlabel('number of samples', 'fontsize', 14);
ylabel('runtime (sec)', 'fontsize', 14);
title('Runtime on Asia network', 'fontsize', 14);
legend('ours', 'BIC', 'MMHC', 'GBN');

subplot(2, 3, 5)
hold on
plot(x, fliplr(y1), 'b-', 'linewidth', 2);
plot(x, fliplr(y3), 'g-.', 'linewidth', 2);
plot(x, fliplr(y2), 'r--', 'linewidth', 2);
plot(x, fliplr(y5), 'k-', 'linewidth', 2);
xlabel('number of samples', 'fontsize', 14);
ylabel('runtime (sec)', 'fontsize', 14);
title('Runtime on Child network', 'fontsize', 14);
legend('ours', 'BIC', 'MMHC', 'GBN');

subplot(2, 3, 6)
hold on
plot(x, fliplr(y1), 'b-', 'linewidth', 2);
plot(x, fliplr(y3), 'g-.', 'linewidth', 2);
plot(x, fliplr(y2), 'r--', 'linewidth', 2);
plot(x, fliplr(y5), 'k-', 'linewidth', 2);
xlabel('number of samples', 'fontsize', 14);
ylabel('runtime (sec)', 'fontsize', 14);
title('Runtime on Insurance network', 'fontsize', 14);
legend('ours', 'BIC', 'MMHC', 'GBN');

%%%%%%%% real data

figure
subplot(2, 3, 1)
hold on
plot(x, y1, 'b-', 'linewidth', 2);
plot(x, y3, 'g-.', 'linewidth', 2);
plot(x, y2, 'r--', 'linewidth', 2);
plot(x, y5, 'k-', 'linewidth', 2);
plot(x, y4, 'm:', 'linewidth', 2);
xlabel('number of samples', 'fontsize', 14);
ylabel('Log-likelihood on held out data', 'fontsize', 14);
title('Wine dataset, structure recovery', 'fontsize', 14);
legend('ours', 'BIC', 'MMHC', 'GBN', 'CBN');

subplot(2, 3, 2)
hold on
plot(x, y1, 'b-', 'linewidth', 2);
plot(x, y3, 'g-.', 'linewidth', 2);
plot(x, y2, 'r--', 'linewidth', 2);
plot(x, y5, 'k-', 'linewidth', 2);
plot(x, y4, 'm:', 'linewidth', 2);
xlabel('number of samples', 'fontsize', 14);
ylabel('Log-likelihood on held out data', 'fontsize', 14);
title('Dow-Jones dataset, structure recovery', 'fontsize', 14);
legend('ours', 'BIC', 'MMHC', 'GBN', 'CBN');

subplot(2, 3, 3)
hold on
plot(x, y1, 'b-', 'linewidth', 2);
plot(x, y3, 'g-.', 'linewidth', 2);
plot(x, y2, 'r--', 'linewidth', 2);
plot(x, y5, 'k-', 'linewidth', 2);
xlabel('number of samples', 'fontsize', 14);
ylabel('Log-likelihood on held out data', 'fontsize', 14);
title('T-cell dataset, structure recovery', 'fontsize', 14);
legend('ours', 'BIC', 'MMHC', 'GBN');

subplot(2, 3, 4)
hold on
plot(x, fliplr(y1), 'b-', 'linewidth', 2);
plot(x, fliplr(y3), 'g-.', 'linewidth', 2);
plot(x, fliplr(y2), 'r--', 'linewidth', 2);
plot(x, fliplr(y5), 'k-', 'linewidth', 2);
plot(x, fliplr(y4), 'm:', 'linewidth', 2);
xlabel('number of samples', 'fontsize', 14);
ylabel('runtime (sec)', 'fontsize', 14);
title('Wine dataset, runtime', 'fontsize', 14);
legend('ours', 'BIC', 'MMHC', 'GBN', 'CBN');

subplot(2, 3, 5)
hold on
plot(x, fliplr(y1), 'b-', 'linewidth', 2);
plot(x, fliplr(y3), 'g-.', 'linewidth', 2);
plot(x, fliplr(y2), 'r--', 'linewidth', 2);
plot(x, fliplr(y5), 'k-', 'linewidth', 2);
plot(x, fliplr(y4), 'm:', 'linewidth', 2);
xlabel('number of samples', 'fontsize', 14);
ylabel('runtime (sec)', 'fontsize', 14);
title('Dow Jones dataset, runtime', 'fontsize', 14);
legend('ours', 'BIC', 'MMHC', 'GBN', 'CBN');

subplot(2, 3, 6)
hold on
plot(x, fliplr(y1), 'b-', 'linewidth', 2);
plot(x, fliplr(y3), 'g-.', 'linewidth', 2);
plot(x, fliplr(y2), 'r--', 'linewidth', 2);
plot(x, fliplr(y5), 'k-', 'linewidth', 2);
xlabel('number of samples', 'fontsize', 14);
ylabel('runtime (sec)', 'fontsize', 14);
title('T-cell dataset, runtime', 'fontsize', 14);
legend('ours', 'BIC', 'MMHC', 'GBN');
