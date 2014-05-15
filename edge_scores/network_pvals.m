function [z, ind] = network_pvals(network, type, variance, N, maxS, ...
    pval, save_flag)

bnet = make_bnet(struct('network', network, 'moralize', false, 'arity', 1, 'type', type, 'variance', variance));
kci_opt = struct( 'pval', pval, 'kernel', GaussKernel());
triples = gen_triples(size(bnet.dag, 1), 0:maxS);
p = [];
ind = [];
edge = [];

data = normalize_data(samples(bnet, N));
[D, pre] = preallocate(data, kci_opt);

tic;
for t = 1 : length(triples)
    i = triples{t}.i;
    j = triples{t}.j;
    for c = 1 : length(triples{t}.cond_set)
        p = [p compute_p(D, [i j triples{t}.cond_set{c}], kci_opt, pre)];
        ind = [ind dsep(i, j, triples{t}.cond_set{c}, bnet.dag)];
        edge = [edge logical(bnet.dag(i,j) || bnet.dag(j,i))];
        printf(2, '  %d %d cond set %d \n', i, j, c);
    end
    printf(2, 'DONE WITH %d %d\n', i, j);
end
printf(2, 'total time = %f sec.\n', toc);

% note that the p-values returned by kci are really 1 - p, but this will
% also be uniformly distributed under the null, hence z should still be
% N(0,1)
z = norminv(p); 
ind = logical(ind);

if save_flag
    clear pre
    if pval
        pstr = 'pval';
    else
        pstr = 'rho';
    end
    command = sprintf('save edge_scores/out/%s_%d_%s', network, N, pstr);
    eval(command);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [D, pre] = preallocate(data, kci_opt)

boot_flag = false;

if boot_flag
    assert(0);
    printf(2, 'bootstrapping..\n');
    D = cell(nboot, 1);
    pre = cell(nboot, 1);
    N = size(data, 2);    
    for b = 1 : nboot
        y = randsample(N, N, true); 
        D{b} = data(:, y);
        pre{b} = kci_prealloc(D{b}, kci_opt);
    end
else
    printf(2, 'not bootstrapping.\n');
    D{1} = data;
    pre{1} = kci_prealloc(D{1}, kci_opt);
end

end

function p = compute_p(D, trip, opt, pre)

for b = 1 : length(D)
   p = kci_classifier(D{b}, trip, opt, pre{b}); 
end
if length(p) > 1
    z = norminv(p);
    [~, p] = kstest(z);
end

end


