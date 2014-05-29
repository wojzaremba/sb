function y1 = plot_mixture(mu, sigma, p0, x, y)

y1 = normpdf(x, mu, sigma);

plot(x, y, 'k-', 'linewidth', 2);
hold on

plot(x, y1*p0, 'r-', 'linewidth', 2);

legend('full', 'no edge');