function [SHD, T, bn_opt, rp, learn_opt, bnet, emp] = bn_learn(network, ...
    data_gen, variance, nvec, num_bnet, num_nrep, maxpa, max_condset, ...
    prune_max, psi, nfunc, nvars, plot_flag, save_flag, f_sel)

% initialize
[bn_opt, rp, learn_opt] = init(network, data_gen, variance, nvec, num_bnet, ...
    num_nrep, maxpa, max_condset, prune_max, psi, nfunc, nvars, plot_flag, save_flag, f_sel);

[bnet{1}, bn_opt] = make_bnet(bn_opt);

SHD = cell(length(learn_opt), 1); % hamming distance
T = cell(length(learn_opt), 1); % runtime
emp = cell(rp.num_bnet, rp.num_nrep, length(rp.nvec));

for b = 1:rp.num_bnet       
    for r = 1:rp.num_nrep
        for ni = 1:length(rp.nvec)
            n = rp.nvec(ni);
            emp{b, r, ni} = normalize_data(samples(bnet{b}, n));
            data = emp{b, r, ni};
            for t = 1:length(learn_opt)
                opt = learn_opt{t};
                fprintf('bn %d, N=%d, %s...\n', b, n, opt.name);
                [SHD{t}(b, r, ni), T{t}(b, r, ni)] = ...
                    learn_structure(data, opt, rp, n);
            end     
        end  
        if rp.plot_flag
            update_plot(b, r, rp, learn_opt, SHD, T);
        end
    end
    bnet{b+1} = make_bnet(bn_opt);
end
assert(isequal(numel(SHD{1}), rp.num_bnet*rp.num_nrep*length(rp.nvec)));
bnet = bnet{1:end-1};
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        SHD = compute_shd(G, rp.true_pdag);      
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function SHD = compute_shd(G, true_pdag)
        pred_Pdag = dag_to_cpdag(G);
        SHD = shd(true_pdag,pred_Pdag);
        if ~isequal(true_pdag, pred_Pdag)
            fprintf('predicted G:\n');
            disp(G);
            fprintf('predicted PDAG:\n');
            disp(pred_Pdag);
            fprintf('true PDAG: \n');
            disp(true_pdag);
        end
        fprintf('hamming distance = %d\n', SHD);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function update_plot(b, r, rp, learn_opt, SHD, T)
        clf;
        [h1, h2, leg] = deal([], [], {});
        for c = 1 : length(learn_opt)
            leg{end+1} = learn_opt{c}.name;
            
            subplot(1, 2, 1); hold on
            ham = SHD{c}(1:b, 1:r, :);
            ham
            h1(end+1) = plot(rp.nvec, squeeze(mean(mean(ham, 1), 2)), ...
                learn_opt{c}.color, 'linewidth', 2);
            
            subplot(1, 2, 2); hold on
            tt = T{c}(1:b, 1:r, :);
            tt
            h2(end+1) = plot(rp.nvec, squeeze(mean(mean(tt, 1), 2)), ...
                learn_opt{c}.color, 'linewidth', 2);
        end
        
        subplot(1, 2, 1);
        legend(h1, leg);
        yl = ylim;
        ylim([0 yl(2)]);
        xlabel('number of samples');
        ylabel('structural hamming distance');
        title(sprintf('SHD vs. N, %s network, %d parameter settings, %d reps', ...
            rp.network, b, r), 'fontsize', 14);
        
        subplot(1, 2, 2);
        legend(h2, leg);
        xlabel('number of samples');
        ylabel('runtime (sec)');
        title(sprintf('Runtime vs. N, %s network, %d parameter settings, %d reps', ...
            rp.network, b, r), 'fontsize', 14);
        pause(2);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [S, T] = compute_score(data, opt, rp, n)
        tic;    
        if ~opt.edge && isfield(opt, 'pval')
            opt.pval = false;
        end
               
        % preallocate
        pre = opt.prealloc(data, opt);
        
        % compute base scores
        if strcmpi(opt.method, 'bic')
            S = compute_bic(data, opt.arity, rp.maxpa);
        elseif strcmpi(opt.method, 'sb3')
            S = compute_rho_scores(pre, opt.prune_max, rp.nfunc);
        else
            error('unexpected value for score');
        end
        
        if opt.edge
            E = compute_edge_scores(data, opt, rp.max_condset, pre);
            S = add_edge_scores(S, E, rp.psi, n);
        end;
        S = prune_scores(S);
        T = toc;   
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [bn_opt, rp, learn_opt] = init(network, data_gen, v, nvec, ...
            num_bnet, num_nrep, maxpa, max_condset, prune_max, psi, nfunc, nvars, plot_flag, ...
            save_flag, f_sel)
        
        check_dir();
        rp = struct();
        
        rp.network = network;
        rp.data_gen = data_gen;
        rp.variance = v;
        rp.nvec = nvec;
        rp.num_bnet = num_bnet;
        rp.num_nrep = num_nrep;
        rp.maxpa = maxpa;
        rp.max_condset = max_condset;
        rp.prune_max = prune_max;
        rp.psi = psi;
        rp.nfunc = nfunc;
        rp.plot_flag = plot_flag;
        rp.save_flag = save_flag;
        rp.f_sel = f_sel;
        
        bn_opt = struct('network', network, 'arity', 1, 'data_gen', data_gen, ...
            'variance', v, 'moralize', false, 'n', nvars);
        
        rp.true_pdag = dag_to_cpdag(get_dag(bn_opt));

        full_opt = {
            struct('method', 'mmhc', 'arity', 3, 'edge', false, ...
                'color', 'g-'), ...
            struct('method', 'sb3', 'classifier', @kci_classifier, ...
                'kernel', GaussKernel(),  'arity', 1, 'nfunc', nfunc, ...
                'prealloc', @kci_prealloc, 'pval', false, ...
                'edge', true, 'prune_max', rp.prune_max, 'color', 'm-'), ...
            struct( 'method', 'sb3', 'classifier', @kci_classifier, ...
                'kernel', GaussKernel(),  'arity', 1, 'nfunc', nfunc, ...
                'prealloc', @kci_prealloc, 'pval', true, ...
                'edge', true, 'prune_max', rp.prune_max, 'color', 'r-'), ...
            struct('method', 'bic','classifier', @sb_classifier, ...
                'params', struct('eta', 0.01, 'alpha', 1.0), ...
                'prealloc', @dummy_prealloc, 'arity', 4, ...
                'edge', false, 'color','b-')};
        learn_opt = full_opt(f_sel);
        
        if rp.plot_flag
            figure
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
        
        if rp.save_flag
            check_dir();
            dir_name = sprintf('results/%s', get_date());
            system(['mkdir -p ' dir_name]);
            rp.matfile = sprintf('%s/%s_%s.mat', dir_name, rp.network, func2str(rp.nfunc));
        end

    end

end

