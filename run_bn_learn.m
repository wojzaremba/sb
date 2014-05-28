network = 'asia';
type = 'quadratic_ggm';
variance = 0.05;
Nvec = [1:5]*50;
num_bnet = 3;
num_Nrep = 3;
maxS = 2;
maxK = 10;
psi = 0.1;
plot_flag = true;
save_flag = false;
f_sel = 3;

[SHD, T1, T2] = bn_learn(network, type, variance, Nvec, num_bnet, ...
    num_Nrep, maxS, maxK, psi, plot_flag, save_flag, f_sel);
