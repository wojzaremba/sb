disp('test_bn_learn_synthetic... Warning: not testing KSB')

%% network parameters
in.network = 'chain';
in.data_gen = 'quadratic_ggm';
in.variance = 0.05;
in.nvars = 3;

%% run parameters
in.nvec = 150;
in.num_bnet = 1;
in.num_nrep = 1;
in.plot_flag = false;
in.save_flag = false;
in.f_sel = 3;           % 1=MMHC, 2=KSB, 3=BIC

%% score parameters
in.maxpa = 2;           % max number of parents to allow in learned network
in.max_condset = 2;     % max conditioning set size
in.prune_max = 5;       % number of scores to keep in pruning
in.psi = 1;             % coefficient for edge scores
in.nfunc = @sqrt;

%% test BIC
seed_rand(1);
out = bn_learn_synthetic(in);
assert(out.SHD{1} == 0);

%% test MMHC
seed_rand(1);
in.f_sel = 1;
in.nvec = 300;
in.arity = 3;
in.network = 'Y';
in.data_gen = 'random';
out = bn_learn_synthetic(in);
assert(out.SHD{1} == 0);
