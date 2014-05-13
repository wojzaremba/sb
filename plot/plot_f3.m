function plot_f3()

close all
clear all
load asia_null

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

opt = struct('nbins', 50, 'plot_flag', true, 'color', base_color);
plot_dist(z, opt);

opt.scale = ind_prop;
opt.color = ind_color;
plot_dist(zind, opt);

opt.scale = dep_prop;
opt.color = dep_color;
plot_dist(zdep, opt);

%%% first remove all z's with strong evidence of independence
figure
hold on

z2 = z(find(normcdf(z) > 0.01));
ind2 = ind(find(normcdf(z) > 0.01));
opt.scale = length(z2) / length(z);
opt.color = base_color;
plot_dist(z2, opt);

z2ind = z2(ind2);
ind_prop = length(z2ind) / length(z);
z2dep = z2(~ind2);
dep_prop = length(z2dep) / length(z);
assert(ind_prop + dep_prop == opt.scale);

opt.scale = ind_prop;
opt.color = ind_color;
plot_dist(z2ind, opt);

opt.scale = dep_prop;
opt.color = dep_color;
plot_dist(z2dep, opt);

