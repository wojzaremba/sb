clear all
global debug
debug = 0;

%% network parameters
in.network = 'asia';
in.data_gen = 'quadratic_ggm';
in.variance = 0.05;
in.nvars = 4;

%% run parameters
in.nvec = (1:2)*50;
in.num_bnet = 2;
in.num_nrep = 1;
in.plot_flag = true;
in.save_flag = false;
in.f_sel = [1 3];       % 1=MMHC, 2=KSB no pval, 3=KSB pval, 4 = BIC

%% score parameters
in.maxpa = 2;           % max number of parents to allow in learned network
in.max_condset = 2;     % max conditioning set size
in.prune_max = 20;      % number of scores to keep in pruning
in.psi = 1;             % coefficient for edge scores
in.nfunc = @my_one;     % divide by one

%% go
if in.maxpa > 2
    fprintf(['warning- sb3 limited to two parents, while BIC and MMHC' ...
        'can have more than 2\n']);
end
seed_rand(1);
out = bn_learn_synthetic(in);
if out.rp.save_flag
    eval(['save ' out.rp.matfile]);
end
