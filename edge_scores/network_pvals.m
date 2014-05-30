function out = network_pvals(network, data_gen, variance, N, maxS, save_flag)

tic;
bnet = make_bnet(struct('network', network, 'moralize', false, ...
    'arity', 1, 'data_gen', data_gen, 'variance', variance));
kci_opt = struct( 'pval', true, 'kernel', GaussKernel());
triples = gen_triples(size(bnet.dag, 1), 0:maxS);
data = normalize_data(samples(bnet, N));
pre = kci_prealloc(data, kci_opt);
num_tests = length(triples)*length(triples{1}.cond_set);
[out.p, out.sta, out.edge, out.ind, out.set_size] = ...
    deal(ones(num_tests, 1) * NaN);

idx = 1;
for t = 1:length(triples)
    i = triples{t}.i;
    j = triples{t}.j;
    for c = 1:length(triples{t}.cond_set)
        trip = [i, j, triples{t}.cond_set{c}];
        [~, info] = kci_classifier(data, trip, kci_opt, pre);
        out.p(idx) = 1 - info.pval;
        out.sta(idx) = info.Sta;
        out.edge(idx) = (bnet.dag(i,j) || bnet.dag(j,i));
        out.ind(idx) = dsep(i, j, triples{t}.cond_set{c}, bnet.dag);
        out.set_size(idx) = length(triples{t}.cond_set{c});
        idx = idx + 1;
    end
    fprintf('  done with %d %d\n', i, j);
end

clear pre;
save_to_mat(save_flag, network, N);
printf(2, 'total time = %f sec.\n', toc);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function save_to_mat(save_flag, network, N)
    if save_flag
        datestr = get_date();
        dir_name = sprintf('edge_scores/pval_mats/%s', datestr);
        system(['mkdir -p ' dir_name]);
        command = sprintf('save(''%s/%s_%d_pvals'', ''out'')', dir_name, network, N);
        eval(command);
    end
end

end





