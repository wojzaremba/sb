function [y1, y2, y3, x] = plot_empirical_pvals(z, ind, edge, plot_flag)
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
third_color = 'b-';

% subset z
zind = z(ind);
ind_prop = length(find(ind)) / length(z);
zdep = z(~ind);
dep_prop = length(find(~ind)) / length(z);
z_no_edge = z(~edge);
no_edge_prop = length(find(~edge)) / length(z);
z_edge = z(logical(edge));
edge_prop = length(find(edge)) / length(z);
z_indirect = z(logical((~edge) .* (~ind)));
indirect_prop = length(z_indirect) / length(z);
assert(edge_prop + no_edge_prop == 1);
assert(ind_prop + dep_prop == 1);
assert(ind_prop <= no_edge_prop && no_edge_prop <= 1);

opt = struct('nbins', 30, 'color', base_color, 'plot_flag', plot_flag);

% all
[y1, x] = plot_dist(z, method, opt);

% ind
opt.scale = ind_prop;
opt.color = ind_color;
opt.x = x;
[y2] = plot_dist(zind, method, opt);

% direct dep
opt.color = third_color;
opt.scale = edge_prop;
y3 = plot_dist(z_edge, method, opt);

opt.color = [third_color '-'];
opt.scale = 1 - edge_prop;
y4 = plot_dist(z_no_edge, method, opt);

% if indirect_prop ~= 0
%     opt.color = 'm-';
%     opt.scale = indirect_prop;
%     y4 = plot_dist(z_indirect, method, opt);
% end

if plot_flag
    legend('full', 'indep', 'edge', 'no edge'); %, 'indirect dep');
end


% opt.scale = edge_prop;
% [y1, x] = plot_dist(z_edge, method, opt);
% opt.x = x;
% opt.color = ind_color;
% opt.scale = no_edge_prop;
% [y2] = plot_dist(z_no_edge, method, opt);
% 
% [y1, x] = plot_dist(z, method, opt);
% 


% opt.color = third_color;
% if strcmpi(appx_or_dep, 'dep')
%         opt.scale = dep_prop;
%         [y3] = plot_dist(zdep, method, opt);
%         a = check_aucs(x, y1, y2, y3);
%     
%         opt.scale = no_edge_prop;
%         y3 = plot_dist(z_no_edge, method, opt);
%         legend('all pvals', 'indep pvals', 'all no-edge pvals');
%     
%     opt.scale = edge_prop;
%     y3 = plot_dist(z_edge, method, opt);
%     if (plot_flag)
%         legend('all pvals', 'indep pvals', 'edge pvals');
%     end
% elseif strcmpi(appx_or_dep, 'appx')
%     [f, x] = fit_f(z, false, false);
%     [mu, sigma] = fit_f0(f, x, false);
%     p0 = approx_p0(f, x, mu, sigma);
%     y3 = p0 * normpdf(x, mu, sigma);
%     plot(x, y3, third_color);
%     if plot_flag
%         legend('f', 'f0 true', 'f0 approx');
%     end
% else
%     error('unexpected value for appx_or_dep');
% end



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
%assert(compare_curves(x, y1, x, y2));
%assert(compare_curves(x, y1, x, y3));

end


