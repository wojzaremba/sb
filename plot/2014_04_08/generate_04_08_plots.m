%main;
clear all;
load linear_arity2.mat

% xlims = {};
% ylims = {};
% xlims{1} = [0 1];
% xlims{2} = [0 0.05];
% ylims{1} = [0 1];
% ylims{2} = [0 1];
% xmax = [1.0, 0.05];
skips = {};
skips{1} = [1 2 50 100 50 100];
skips{2} = [1 1 50 10 1 100];
plot_roc_choose_range_all_classifiers;

clear all;
load linear_arity3.mat

skips = {};
skips{1} = [1 2 50 100 50 100];
skips{2} = [1 1 10 10 50 100];
plot_roc_choose_range_all_classifiers;

