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
in.f_sel = 4;           % 1=MMHC, 2=KSB no pval, 3=KSB pval, 4 = BIC

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
in.f_sel = 1;
in.nvec = 300;
in.nvars = 4;
out = bn_learn_synthetic(in);
assert(out.SHD{1} == 0);