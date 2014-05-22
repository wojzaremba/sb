disp('test_bn_learn...')


network = 'asia';
arity = 4;
type = 'quadratic_ggm';
variance = 0.05;
Nvec = 50:50:300;
num_exp = 10;
maxS = 1;
plot_flag = true;
save_flag = false;
f_sel = 1:3;

[SHD, T1, T2] = bn_learn(network, arity, type, variance, Nvec, num_exp, ...
    maxS, plot_flag, save_flag, f_sel);
