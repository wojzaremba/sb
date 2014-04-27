function [SHD, T1, T2] = run_structure_learning()

num_exp = 10;
Nvec = [50:50:500];
arity = 2;
bnet = mk_asia_linear_rand(arity);
true_G = bnet.dag;
true_Pdag = dag_to_cpdag(true_G);
SHD = zeros(num_exp, length(Nvec));
T1 = zeros(num_exp, length(Nvec)); % runtime
T2 = zeros(num_exp, length(Nvec));


o = struct('classifier', @sb_classifier, 'rho_range', rho_range,'prealloc', @dummy_prealloc, 'kernel', empty,'thresholds',thresholds, 'color', 'm','params',struct('eta',0.01,'alpha',1.0),'normalize',false,'name','bayesian conditional MI');

for exp = 1:num_exp
    fprintf('exp %d...\n',exp);
    for N_idx = 1:length(Nvec)
        N = Nvec(N_idx);
        fprintf('N = %d\n', N);
        data = samples(bnet,N);
        [G, T1(exp, N_idx), T2(exp, N_idx)] = run_gobnilp(data, arity);
        pred_Pdag = dag_to_cpdag(G);
        SHD(exp,N_idx) = shd(true_Pdag,pred_Pdag); 
    end
end

plot(Nvec, mean(SHD, 1));
xlabel('number of samples');
ylabel('structural hamming distance');
title('SHD vs. N, asia network, random CPDs, arity=2');

figure
T = T1 + T2;
h(1) = plot(Nvec, mean(T1, 1));
hold on
h(2) = plot(Nvec, mean(T2, 1));
xlabel('number of samples');
ylabel('runtime (sec)');
title('Runtime vs. N, asia network, random CPDs, arity=2');
legend(h,{'score time', 'structure search'});

