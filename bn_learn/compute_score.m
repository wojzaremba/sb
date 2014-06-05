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
        %S = compute_rho_scores(pre, opt.prune_max, rp.nfunc);
        S = compute_likelihood(data, rp.maxpa);
    else
        error('unexpected value for score');
    end
    
    if opt.edge
        E = compute_edge_scores(data, opt, rp.max_condset, pre);
        S = add_edge_scores(S, E, rp.psi, N);
    end;
    S = prune_scores(S);
    T = toc;
end
