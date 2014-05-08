function learn_mrf_large(K)

randn('seed', 1);
rand('seed', 1);

assert(0);
bn_opt = struct('network', dag, 'variance', 0.05, 'type', 'quadratic_ggm', 'moralize', false, 'arity', 1);
bnet = make_bnet(bn_opt);

data = normalize_data(samples(bnet, 1000);

edge_ps = [];
indep_ps = [];

edge_rhos = [];
indep_rhos = [];

for i = 1 : K
    for j = i + 1 : K
        
    end
end