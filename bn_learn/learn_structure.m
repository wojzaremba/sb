function [SHD, t] = learn_structure(data, opt, rp, n)
    if (strcmpi(opt.method, 'sb3') || strcmpi(opt.method, 'bic'))
        data = discretize_data(data, opt.arity);
        [S, t1] = compute_score(data, opt, rp, n);
        [G, t2] = run_gobnilp(S);
        t = t1 + t2;
    elseif strcmpi(opt.method, 'mmhc')
        [G, t] = mmhc(data', opt.arity);
    else
        error('unexpected opt.method');
    end
    SHD = compute_shd(G, rp.true_pdag, false);
end