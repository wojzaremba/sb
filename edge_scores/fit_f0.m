function [mu, sigma] = fit_f0(f, x, plot_flag)

% find x value at peak, check that it is roughly near 0
[~, idx] = max(f);
mu = x(idx);
assert(abs(mu) < 1);

% subset x range to be within 1.5 units of peak
idx2fit = find((x >= mu - 1) .* (x <= mu + 1));
x2fit = x(idx2fit);
f2fit = f(idx2fit); 

% fit a quadratic to log(f) in this range
[a, S] = polyfit(x2fit, log(f2fit), 2);
assert(S.normr < 0.1);
sigma = 1 / sqrt(-2*a(1));

% plot
if plot_flag
    figure
    hold on
    y = a(1)*x2fit.^2 + a(2)*x2fit + a(3);
    plot(x2fit, log(f2fit), 'b*-');
    plot(x2fit, y, 'k*-');
    yl = get(gca, 'ylim');
    line([mu mu], yl, 'Color', 'r');
    legend('f', 'polynomial fit');
    title('quadratic polynomial fit to density', 'fontsize', 14);
end


