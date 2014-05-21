disp('test_bn_learn...')


network = 'chain';
arity = 5;
type = 'quadratic_ggm';
variance = 0.05;
Nvec = [1:4]*1000;
num_exp = 10;
maxS = 1;
plot_flag = true;
save_flag = false;
f_sel = 1;

[SHD, T1, T2] = bn_learn(network, arity, type, variance, Nvec, num_exp, ...
    maxS, plot_flag, save_flag, f_sel);
