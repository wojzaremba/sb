function [a] = plot_f3(filename)

use_ks = true;

command = sprintf('load %s', filename);
eval(command);

% throw out infinite values (I think we will need to account for these by
% adjust p_0 appropriately)
ind = ind(~isinf(z));
z = z(~isinf(z));

base_color = 'k-';
ind_color = 'r-';
dep_color = 'b-';

zind = z(ind);
ind_prop = length(find(ind)) / length(z);
zdep = z(~ind);
dep_prop = length(find(~ind)) / length(z);
assert(ind_prop + dep_prop == 1);

figure
hold on

if ~use_ks
    opt = struct('nbins', 30, 'plot_flag', true, 'color', base_color);
    [y1, x] = density_est(z, opt);
else
    [y1, x] = ksdensity(z);
    plot(x, y1, base_color);
end
a(1) = auc(x', y1', max(x), min(x));

if ~use_ks
    opt.scale = ind_prop;
    opt.color = ind_color;
    [y2, x] = density_est(zind, opt);
else
    [y2] = ksdensity(zind, x);
    y2 = y2 * ind_prop;
    plot(x, y2, ind_color);
end
a(2) = auc(x', y2', max(x), min(x));

if ~use_ks
    opt.scale = dep_prop;
    opt.color = dep_color;
    [y3, x] = density_est(zdep, opt);
else
    %[y, x] = ksdensity(zdep);
    %y = y * dep_prop;
    y3 = y1 - y2;
    plot(x, y3, dep_color);
end
a(3) = auc(x', y3', max(x), min(x));

assert(a(1) - (a(2) + a(3)) < 1e-2);

legend('all pvalues', 'pvalsfrom ind', 'pvals from dep');

