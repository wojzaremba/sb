
% network parameters
network = 'asia';
data_gen = 'quadratic_ggm';
variance = 0.05;
nvars = [];

% run parameters
nvec = [1:8]*50;
num_bnet = 3;
num_nrep = 3;
plot_flag = true;
save_flag = false;
f_sel = [1 2];

% learning parameters
maxpa = 2;          % max number of parents to allow in learned network
max_condset = 2;    % max conditioning set size
prune_max = 5;      % number of scores to keep in pruning
psi = 0.1;          % coefficient for edge scores

if maxpa > 2
    fprintf(['warning- sb3 limited to two parents, while BIC and MMHC' ...
        'can have more than 2\n']);
end

bn_learn(network, data_gen, variance, nvec, num_bnet, num_nrep, maxpa, ...
    max_condset, prune_max, psi, nvars, plot_flag, save_flag, f_sel);
