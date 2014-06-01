disp('test_bn_learn...(warning- not testing sb3)')

seed_rand(1);

% network parameters
network = 'chain';
data_gen = 'quadratic_ggm';
variance = 0.05;
nvars = 3;

% run parameters
nvec = 150;
num_bnet = 1;
num_nrep = 1;
plot_flag = false;
save_flag = false;
f_sel = 4;

% learning parameters
maxpa = 2;              % max number of parents to allow in learned network
max_condset = 2;        % max conditioning set size
prune_max = 5;          % number of scores to keep in pruning
psi = 1;              % coefficient for edge scores
nfunc = @sqrt;

% test BIC
SHD = bn_learn(network, data_gen, variance, nvec, num_bnet, num_nrep, ...
    maxpa, max_condset, prune_max, psi, nfunc, nvars, plot_flag, save_flag, f_sel);
assert(SHD{1} == 0);

% test MMHC
f_sel = 4;
nvec = 300;
nvars = 4;
SHD = bn_learn(network, data_gen, variance, nvec, num_bnet, num_nrep, ...
    maxpa, max_condset, prune_max, psi, nfunc, nvars, plot_flag, save_flag, f_sel);
assert(SHD{1} == 0);


