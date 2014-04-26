function run_structure_learning()

num_exp = 10;
Nvec = [50:50:500];
arity = 2;
bnet = mk_asia_linear_rand(arity);
true_G = bnet.dag;
true_Pdag = dag_to_cpdag(true_G);
SHD = zeros(num_exp,length(Nvec));
T = zeros(num_exp,length(Nvec)); % runtime

for exp = 1:num_exp
    for N_idx = 1:length(Nvec)
        N = Nvec(N_idx);
        data = samples(bnet,N);
        [G,T(exp,N_idx)] = run_gobnilp(data, arity);
        pred_Pdag = dag_to_cpdag(G);
        SHD(exp,N_idx) = shd(true_Pdag,pred_Pdag); 
    end
end

plot(Nvec, mean(SHD, 1));
xlabel('number of samples');
ylabel('structural hamming distance');
title('SHD vs. N, asia network, random CPDs, arity=2');

figure
plot(Nvec, mean(T, 1));
xlabel('number of samples');
ylabel('runtime (sec)');
title('Runtime vs. N, asia network, random CPDs, arity=2');

