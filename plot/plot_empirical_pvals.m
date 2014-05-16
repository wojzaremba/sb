function [y1, y2, y3, x, a] = plot_empirical_pvals(z, ind, plot_flag)

method = 'ks';

if ~exist('plot_flag', 'var')
    plot_flag = true;
end
    
% just throw out infinite values
printf(2, '  throwing out %d inf values\n', length(find(isinf(z))));
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

if plot_flag
    figure
    hold on
end

opt = struct('nbins', 30, 'color', base_color, 'plot_flag', plot_flag);
[y1, x] = plot_dist(z, method, opt);

opt.scale = ind_prop;
opt.color = ind_color;
opt.x = x;
[y2] = plot_dist(zind, method, opt);

opt.scale = dep_prop;
opt.color = dep_color;
[y3] = plot_dist(zdep, method, opt);
%     y3 = y1 - y2;
%    plot(x, y3, dep_color);

a = check_aucs(x, y1, y2, y3);

if plot_flag
    legend('all pvals', 'pvals from ind', 'pvals from dep');
end

end


%%%%%%%%%%%%%


function [y, x] = plot_dist(z, method, opt)

% set defaults
if ~isfield(opt, 'nbins')
    opt.nbins = 30;
end

if ~isfield(opt, 'color')
    opt.color = 'b-';
end

% compute y
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
        plot(x, y, opt.color);
    end
end

end

function a = check_aucs(x, y1, y2, y3)
a(1) = auc(x', y1'); %, max(x), min(x));
a(2) = auc(x', y2'); %, max(x), min(x));
a(3) = auc(x', y3'); %, max(x), min(x));
assert(abs(a(1) - (a(2) + a(3))) < 1e-2);
assert(abs(a(1) - 1) < 1e-2);
end

