function [G, t] = learn_structure(data, opt, rp)
    if opt.normalize
       data = normalize_data(data); 
    end
    if opt.discretize
        data = discretize_data(data, opt.arity);
    end
    if (strcmpi(opt.method, 'ksb') || strcmpi(opt.method, 'bic'))
        [S, t1] = compute_score(data, opt, rp);
        [G, t2] = run_gobnilp(S);
        t = t1 + t2;
    elseif strcmpi(opt.method, 'mmhc')
        [G, t] = mmhc(data', opt.arity);
    else
        error('unexpected opt.method');
    end
end
