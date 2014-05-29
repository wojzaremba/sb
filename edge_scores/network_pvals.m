function [z, ind, edge, rho, set_size, k] = network_pvals(network, data_gen, variance, N, ...
    maxS, pval, save_flag)

bnet = make_bnet(struct('network', network, 'moralize', false, ...
    'arity', 1, 'data_gen', data_gen, 'variance', variance));
kci_opt = struct( 'pval', pval, 'kernel', GaussKernel());
triples = gen_triples(size(bnet.dag, 1), 0:maxS);
data = normalize_data(samples(bnet, N));
pre = kci_prealloc(data, kci_opt);

tic;
p = ones(size(bnet.dag, 1)) * Inf;
ind = ones(size(bnet.dag, 1)) * Inf;
rho = ones(size(bnet.dag, 1)) * Inf;
set_size = ones(size(bnet.dag, 1)) * Inf;
edge = bnet.dag;
for t = 1 : length(triples)
    i = triples{t}.i;
    j = triples{t}.j;
    [p(i, j), info] = classifier_wrapper(data, triples{t}, @kci_classifier, kci_opt, pre); 
    rho(i,j) = info.rho;
    ind(i, j) = dsep(i, j, info.cond_set, bnet.dag);
    set_size(i,j) = length(info.cond_set);
    printf(2, 'DONE WITH %d %d\n', i, j);
end
printf(2, 'total time = %f sec.\n', toc);

% note that the p-values returned by kci are really 1 - p, but this will
% also be uniformly distributed under the null, hence z should still be
% N(0,1)
z = norminv(p); 
ind = logical(ind(~isnan(z)));
edge = edge(~isnan(z));
rho = rho(~isnan(z));
set_size = set_size(~isnan(z));
z = z(~isnan(z));
k = length(triples{1}.cond_set);

if save_flag
    clear pre
    if pval
        pstr = 'pval';
    else
        pstr = 'rho';
    end
    datestr = get_date();
    dir_name = sprintf('edge_scores/pval_mats/%s', datestr);
    system(['mkdir -p ' dir_name]); 
    command = sprintf('save %s/%s_%d_%s', dir_name, network, N, pstr);
    eval(command);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function [D, pre] = preallocate(data, kci_opt)
% 
% boot_flag = false;
% 
% if boot_flag
%     assert(0);
%     printf(2, 'bootstrapping..\n');
%     D = cell(nboot, 1);
%     pre = cell(nboot, 1);
%     N = size(data, 2);    
%     for b = 1 : nboot
%         y = randsample(N, N, true); 
%         D{b} = data(:, y);
%         pre{b} = kci_prealloc(D{b}, kci_opt);
%     end
% else
%     printf(2, 'not bootstrapping.\n');
%     D{1} = data;
%     pre{1} = kci_prealloc(D{1}, kci_opt);
% end
% 
% end
% 
% function [p, info] = compute_p(D, trip, opt, pre)
% 
% info = {};
% for b = 1 : length(D)
%    [p(b), info{b}] = kci_classifier(D{b}, trip, opt, pre{b}); 
% end
% if length(p) > 1
%     z = norminv(p);
%     [~, p] = kstest(z);
% end
% 
% end


