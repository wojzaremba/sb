disp('test_bn_learn...')


network = 'asia';
arity = 4;
type = 'quadratic_ggm';
variance = 0.05;
Nvec = 100;
num_exp = 10;
maxS = 2;
psi = 1;
plot_flag = true;
save_flag = false;
f_sel = 3;

[SHD, T1, T2] = bn_learn(network, arity, type, variance, Nvec, num_exp, ...
    maxS, psi, plot_flag, save_flag, f_sel);
