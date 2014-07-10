%clear all
global debug
debug = 0;

%% network parameters
in.network = 'chain';
in.data_gen = 'quadratic_ggm';
in.variance = 0.05;
in.nvars = 4;
in.tile = 2;

%% run parameters
in.nvec = 100*(1:4);
in.num_bnet = 3;
in.num_nrep = 3;
in.plot_flag = true;
in.save_flag = false;
in.f_sel = 2;           % 1=MMHC, 2=KSB, 3=BIC
in.parallel = true;

%% score parameters
in.maxpa = 2;           % max number of parents to allow in learned network
in.max_condset = 2;     % max conditioning set size %%%%%%XXX
in.prune_max = 10;      % number of scores to keep in pruning
in.psi = 10;             % coefficient for edge scores
in.nfunc = @my_one;     % divide by one

%% go
if in.maxpa > 2
    fprintf(['warning- sb3 limited to two parents, while BIC and MMHC' ...
        'can have more than 2\n']);
end
seed_rand(1);
out = bn_learn_synthetic(in);
