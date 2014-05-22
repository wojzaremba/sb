function [y1, y2, y3, x, a] = plot_empirical_pvals(z, ind, plot_flag)
% always plot full empirical distribution and the true (empirical) null,
% but choose whether the third plot is the approximated null or the true
% distribution from dependent pairs

appx_or_dep = 'dep';
method = 'ks';

% initialize
if ~exist('plot_flag', 'var')
    plot_flag = true;
end
base_color = 'k-';
ind_color = 'r-';
third_color = 'r--';
    
% throw out infinite values
if ~isempty(find(isinf(z), 1))
    printf(2, '  throwing out %d inf values\n', length(find(isinf(z))));
    ind = ind(~isinf(z));
    z = z(~isinf(z));
end

% subset z
zind = z(ind);
ind_prop = length(find(ind)) / length(z);
zdep = z(~ind);
dep_prop = length(find(~ind)) / length(z);
assert(ind_prop + dep_prop == 1);

% if plot_flag
%     figure
%     hold on
% end

opt = struct('nbins', 30, 'color', base_color, 'plot_flag', plot_flag);
[y1, x] = plot_dist(z, method, opt);

opt.scale = ind_prop;
opt.color = ind_color;
opt.x = x;
[y2] = plot_dist(zind, method, opt);

opt.color = third_color;
if strcmpi(appx_or_dep, 'dep')
    opt.scale = dep_prop;
    [y3] = plot_dist(zdep, method, opt);
    %y3 = y1 - y2;
    %plot(x, y3, dep_color);
    a = check_aucs(x, y1, y2, y3);
    legend_str = 'f1 empirical';
elseif strcmpi(appx_or_dep, 'appx')
    [f, x] = fit_f(z, false, false);
    [mu, sigma] = fit_f0(f, x, false)
    p0 = approx_p0(f, x, mu, sigma)
    y3 = p0 * normpdf(x, mu, sigma);
    legend_str = sprintf('f0 approx');
    plot(x, y3, third_color);
else
    error('unexpected value for appx_or_dep');
end

if plot_flag
    legend('f empirical', 'f0 empirical', legend_str);
end


%%%%%%%%%%%%%%%%%%%%%%%


function [y, x] = plot_dist(z, method, opt)

% set defaults
if ~isfield(opt, 'nbins')
    opt.nbins = 30;
end

if ~isfield(opt, 'color')
    opt.color = 'b-';
end

% compute x and y
if strcmpi(method, 'ks')
    if isfield(opt, 'x')
        x = opt.x;
        y = ksdensity(z, x);
    else
        [y, x] = ksdensity(z);
    end
elseif strcmpi(method, 'density_est')
    [y, x] = density_est(z, struct('plot_flag', false, 'nbins', opt.nbins));
    
elseif strcmpi(method, 'hist')
    [y, x] = hist(z, opt.nbins);
    width = x(2) - x(1);
    y = y / (sum(y) * width);
elseif strcmpi(method, 'done')
    y = opt.y;
    x = opt.x;
else
    error('Unexpected method for plot_dist');
end

% rescale
if isfield(opt, 'scale')
    y = y * opt.scale;
end

% plot
if opt.plot_flag
    if strcmpi(method, 'hist')
        bar(x, y);
        figure;
    else
        plot(x, y, opt.color, 'linewidth', 2);
        hold on
    end
end

end

function a = check_aucs(x, y1, y2, y3)
a(1) = auc(x', y1'); %, max(x), min(x));
a(2) = auc(x', y2'); %, max(x), min(x));
a(3) = auc(x', y3'); %, max(x), min(x));
if strcmpi(appx_or_dep, 'dep')
assert(abs(a(1) - (a(2) + a(3))) < 1e-2);
elseif strcmpi(appx_or_dep, 'appx')
    assert(abs(a(2) - a(3)) < 0.1);
    assert(abs(a(3) - p0) < 1e-4);
else
    error('unexpected approx_or_dep');
end
assert(abs(a(1) - 1) < 1e-2);
end
% check that full distribution lies completely above null distribution
% (with some error tolerance epsilon defined in compare_curves)
assert(compare_curves(x, y1, x, y2));
%assert(compare_curves(x, y1, x, y3));

end


