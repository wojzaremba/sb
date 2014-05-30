
% network parameters
network = 'asia';
data_gen = 'quadratic_ggm';
variance = 0.05;
nvars = 8;
maxpa = 2;          % max number of parents to allow in learned network
max_condset = 2;    % max conditioning set size

% bn_learn parameters
nvec = (1:5)*1000;
num_bnet = 3;
num_nrep = 3;
plot_flag = true;
save_flag = false;
f_sel = 4; 

% score parameters
prune_max = 20;     % number of scores to keep in pruning
psi = 1;            % coefficient for edge scores
nfunc = @sqrt;

if maxpa > 2
    fprintf(['warning- sb3 limited to two parents, while BIC and MMHC' ...
        'can have more than 2\n']);
end

randn('seed', 1);


[SHD, T, bn_opt, rp, learn_opt, bnet, emp] = ...
bn_learn(network, data_gen, variance, nvec, num_bnet, num_nrep, maxpa, ...
    max_condset, prune_max, psi, nfunc, nvars, plot_flag, save_flag, f_sel);

if rp.save_flag
    eval(['save ' rp.matfile]);
end
