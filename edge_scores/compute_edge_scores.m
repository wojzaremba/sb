function [E, edge_opt] = compute_edge_scores(emp, opt, maxS, pre)

nvars = size(emp, 1);
triples = flatten_triples(gen_triples(nvars, 0:maxS));

if ~exist('pre', 'var')
    if isfield(opt, 'prealloc')
        pre = opt.prealloc(emp, opt);
    else
        pre = [];
    end
end

[p_all, set_size] = deal(NaN * ones(length(triples), 1));
edge_all = deal(NaN * ones(length(triples), 2));

% compute all pvals
for t = 1:length(triples)
    tr = triples{t};
    [~, info] = kci_classifier(emp, [tr.i, tr.j, tr.cond_set], opt, pre);
    p_all(t) = 1 - info.pval;
    set_size(t) = length(tr.cond_set);
    edge_all(t, :) = sort([tr.i, tr.j]);
end

% partition into different conditioning set sizes and compute sb scores
E = zeros(nvars);
for k = 0:maxS
    % compute sb scores for conditioning sets of size k
    [sb, edge_opt{k + 1}] = learn_edge_classifier(p_all(set_size == k), k, true);
    
    % get max sb score for each edge
    edge = edge_all(set_size == k, :);
    for t = 1 : length(sb)
        i = edge(t, 1);
        j = edge(t, 2);
        E(i, j) = max(E(i, j), sb(t));
    end
end

end



