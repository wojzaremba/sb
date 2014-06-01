clear all
global debug
debug = 0;

% network parameters
in.network = 'asia';
in.data_gen = 'quadratic_ggm';
in.variance = 0.05;
in.nvars = 4;
in.maxpa = 2;          % max number of parents to allow in learned network
in.max_condset = 2;    % max conditioning set size

% bn_learn parameters
in.nvec = 100;
in.num_bnet = 1;
in.num_nrep = 1;
in.plot_flag = false;
in.save_flag = false;
in.f_sel = 3; 

% score parameters
in.prune_max = 20;     % number of scores to keep in pruning
in.psi = 1;            % coefficient for edge scores
in.nfunc = @my_one;    % divide by one

if in.maxpa > 2
    fprintf(['warning- sb3 limited to two parents, while BIC and MMHC' ...
        'can have more than 2\n']);
end

seed_rand(1);
out = bn_learn(in);

if out.rp.save_flag
    eval(['save ' out.rp.matfile]);
end
