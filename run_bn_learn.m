
% network parameters
network = 'asia';
type = 'quadratic_ggm';
variance = 0.05;

% run parameters
Nvec = [1:8]*50;
num_bnet = 3;
num_Nrep = 3;
plot_flag = true;
save_flag = false;
f_sel = 1;

% learning parameters
maxpa = 2; % max number of parents to allow in learned network
maxS = 2; % max conditioning set size
maxK = 5; % number of scores to keep in pruning
psi = 0.1; % coefficient for edge scores

if maxpa > 2
    fprintf(['warning- sb3 limited to two parents, while BIC and MMHC' ...
        'can have more than 2\n']);
end

[SHD, T1, T2] = bn_learn(network, type, variance, Nvec, num_bnet, ...
    num_Nrep, maxpa, maxS, maxK, psi, plot_flag, save_flag, f_sel);
