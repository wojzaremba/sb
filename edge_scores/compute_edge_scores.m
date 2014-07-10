function [E, edge_opt, P, K] = compute_edge_scores(emp, opt, maxS, pre)

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

[E, edge_opt, P, K] = p2e(nvars, maxS, p_all, set_size, edge_all);

end



