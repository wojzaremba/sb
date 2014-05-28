
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
maxS = 2;
maxK = 5;
psi = 0.1;

[SHD, T1, T2] = bn_learn(network, type, variance, Nvec, num_bnet, ...
    num_Nrep, maxS, maxK, psi, plot_flag, save_flag, f_sel);
