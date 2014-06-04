function out = network_pvals(network, data_gen, variance, N, maxS, ...
    save_flag, run_parallel)

tic;
bnet = make_bnet(struct('network', network, 'moralize', false, ...
    'arity', 1, 'data_gen', data_gen, 'variance', variance));
kci_opt = struct( 'pval', true, 'kernel', GaussKernel());
triples = flatten_triples(gen_triples(size(bnet.dag, 1), 0:maxS));
data = normalize_data(samples(bnet, N));
pre = kci_prealloc(data, kci_opt);
[p, sta, edge, ind, set_size] = deal(ones(length(triples), 1) * NaN);

tic;
if run_parallel
    parfor t = 1:length(triples)
        tr = triples{t};
        [i, j] = deal(tr.i, tr.j);
        [~, info] = kci_classifier(data, [i, j, tr.cond_set], kci_opt, pre);
        p(t) = 1 - info.pval;
        sta(t) = info.Sta;
        edge(t) = (bnet.dag(i,j) || bnet.dag(j,i));
        ind(t) = dsep(i, j, tr.cond_set, bnet.dag);
        set_size(t) = length(tr.cond_set);
        fprintf('finished %d %d %s\n', i, j, num2str(tr.cond_set));
    end
else
    for t = 1:length(triples)
        tr = triples{t};
        [i, j] = deal(tr.i, tr.j);
        [~, info] = kci_classifier(data, [i, j, tr.cond_set], kci_opt, pre);
        p(t) = 1 - info.pval;
        sta(t) = info.Sta;
        edge(t) = (bnet.dag(i,j) || bnet.dag(j,i));
        ind(t) = dsep(i, j, tr.cond_set, bnet.dag);
        set_size(t) = length(tr.cond_set);
        fprintf('finished %d %d %s\n', i, j, num2str(tr.cond_set));
    end
end
fprintf('for loop took %f seconds\n', toc);

[out.p, out.sta, out.edge, out.ind, out.set_size, out.data] = ...
    deal(p, sta, edge, ind, set_size, data);
clear pre p sta edge ind set_size
save_to_mat(save_flag, network, N);
printf(2, 'total time = %f sec.\n', toc);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function save_to_mat(save_flag, network, N)
        if save_flag
            datestr = get_date();
            dir_name = sprintf('edge_scores/pval_mats/%s', datestr);
            system(['mkdir -p ' dir_name]);
            command = sprintf('save(''%s/%s_%d_reg_eps'', ''out'')', dir_name, network, N);
            eval(command);
        end
    end


end





