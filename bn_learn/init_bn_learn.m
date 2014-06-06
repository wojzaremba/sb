function [rp, learn_opt, max_arity] = init_bn_learn(in)

    check_dir();
    rp = in;
    learn_opt = get_learners(rp);

    max_arity = 2;
    for f = 1:length(learn_opt)
        max_arity = max(max_arity, learn_opt{f}.arity);
    end
    
    for c = 1:length(learn_opt)
        o = learn_opt{c};
        if o.arity == 1
            str = ', cts data';
        else
            str = sprintf(', arity %d', o.arity);
        end
        if isfield(o, 'edge')
            str = [str sprintf(', %s edge scores', repmat('no', ~o.edge))];
        end
        if isfield(o, 'pval')
            str = [str sprintf(', %s pval', repmat('no', ~o.pval))];
        end
        learn_opt{c}.name = sprintf('%s%s', o.method, str);
    end
    
    if rp.plot_flag
        h = figure(1);
        set(h, 'units', 'inches', 'position', [4 4 12 8]);
    end

end
