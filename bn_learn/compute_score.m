function [S, T] = compute_score(data, opt, rp, N)
    tic;
    if ~opt.edge && isfield(opt, 'pval')
        opt.pval = false;
    end
    
    % preallocate
    pre = opt.prealloc(data, opt);
    
    % compute base scores
    if strcmpi(opt.method, 'bic')
        S = compute_bic(data, opt.arity, rp.maxpa);
    elseif strcmpi(opt.method, 'ksb')
        S = compute_likelihood(data, rp.maxpa);
        disp('LIKELIHOOD:');
        find_best_parents(S)
    else
        error('unexpected value for score');
    end
    
    if opt.edge
        [E, edge_opt, P, K] = compute_edge_scores(data, opt, ...
            rp.max_condset, pre)
        
        skel = logical(rp.true_pdag + rp.true_pdag');
        idx_edge = find(triu(ones(size(E)), 1) .* skel);
        idx_noedge = find(triu(ones(size(E)), 1) .* ~skel);
        disp(sprintf('MAX edge score among edges: %f, MIN among non-edges: %f',...
            max(E(idx_edge)), min(E(idx_noedge)))); % XXX
        disp('WITH EDGE SCORES:');
        S = add_edge_scores(S, E, rp.psi, N);

    end;
    S = prune_scores(S);
    find_best_parents(S)
    T = toc;
end
