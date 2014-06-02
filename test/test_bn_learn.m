disp('test_bn_learn...(warning- not testing sb3)')

seed_rand(1);

% network parameters
in.network = 'chain';
in.data_gen = 'quadratic_ggm';
in.variance = 0.05;
in.nvars = 3;

% run parameters
in.nvec = 150;
in.num_bnet = 1;
in.num_nrep = 1;
in.plot_flag = false;
in.save_flag = false;
in.f_sel = 4;

% learning parameters
in.maxpa = 2;              % max number of parents to allow in learned network
in.max_condset = 2;        % max conditioning set size
in.prune_max = 5;          % number of scores to keep in pruning
in.psi = 1;              % coefficient for edge scores
in.nfunc = @sqrt;

% test BIC
out = bn_learn(in);
assert(out.SHD{1} == 0);

% test MMHC
in.f_sel = 4;
in.nvec = 300;
in.nvars = 4;
out = bn_learn(in);
assert(out.SHD{1} == 0);


