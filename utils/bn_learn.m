function [SHD, T, bn_opt, rp, c_opt, data] = bn_learn(network, ...
    type, variance, Nvec, num_bnet, num_Nrep, maxpa, maxS, maxK, psi, ..., 
    plot_flag, save_flag, f_sel)

% initialize
[bn_opt, bnet, rp, c_opt, true_Pdag, SHD, T] = init(network, ...
    type, variance, Nvec, num_bnet, num_Nrep, maxpa, maxS, maxK, psi, ...
    plot_flag, save_flag, f_sel);

for bn = 1:rp.num_bnet       
    for Nrep = 1:rp.num_Nrep
        for N_idx = 1:length(rp.Nvec)
            N = rp.Nvec(N_idx);
            data = normalize_data(samples(bnet, N));
            for t = 1:length(c_opt)
                opt = c_opt{t};
                fprintf('bn %d, N=%d, %s...\n', bn, N, opt.name);
                [SHD{t}(bn, Nrep, N_idx), T{t}(bn, Nrep, N_idx)] = ...
                    learn_structure(data, opt, true_Pdag);
            end
            
        end  
        if rp.plot_flag
            update_plot(bn, Nrep, rp, c_opt, SHD);
            pause(2);
        end
    end
    bnet = make_bnet(bn_opt);
end
assert(isequal(size(SHD{1}), [rp.num_bnet rp.num_Nrep length(rp.Nvec)]));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [SHD, t] = learn_structure(data, opt, true_Pdag)       
        if (strcmpi(opt.method, 'sb3') || strcmpi(opt.method, 'bic'))
            data = discretize_data(data, opt.arity);
            [S, t1] = compute_score(data, opt);
            [G, t2] = run_gobnilp(S);
            t = t1 + t2;
        elseif strcmpi(opt.method, 'mmhc')
            [G, t] = mmhc(data', opt.arity);
        else
            error('unexpected opt.method');
        end
        SHD = compute_shd(G, true_Pdag);      
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function SHD = compute_shd(G, true_Pdag)
        pred_Pdag = dag_to_cpdag(G);
        SHD = shd(true_Pdag,pred_Pdag);
        if ~isequal(true_Pdag, pred_Pdag)
            fprintf('predicted PDAG:\n');
            disp(pred_Pdag);
            fprintf('true PDAG: \n');
            disp(true_Pdag);
        end
        fprintf('hamming distance = %d\n', SHD);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function update_plot(bn, Nrep, rp, c_opt, SHD, T)
        clf;
        [h1, h2, leg] = deal([], [], {});
        for c = 1 : length(c_opt)
            leg{end+1} = c_opt{c}.name;
            
            subplot(1, 2, 1); hold on
            ham = SHD{c}(1:bn, 1:Nrep, :);
            h1(end+1) = plot(rp.Nvec, squeeze(mean(mean(ham, 1), 2)), ...
                c_opt{c}.color, 'linewidth', 2);
            
            subplot(1, 2, 2); hold on
            tt = T{c}(1:bn, 1:Nrep, :);
            h2(end+1) = plot(rp.Nvec, squeeze(mean(mean(tt, 1), 2)), ...
                c_opt{c}.color, 'linewidth', 2);
        end
        
        subplot(1, 2, 1);
        legend(h1, leg);
        yl = ylim;
        ylim([0 yl(2)]);
        xlabel('number of samples');
        ylabel('structural hamming distance');
        title(sprintf('SHD vs. N, %s network, %d parameter settings, %d reps', ...
            rp.network, bn, Nrep), 'fontsize', 14);
        
        subplot(1, 2, 2);
        legend(h2, leg);
        xlabel('number of samples');
        ylabel('runtime (sec)');
        title(sprintf('Runtime vs. N, %s network, %d parameter settings, %d reps', ...
            rp.network, bn, Nrep), 'fontsize', 14);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [S, T] = compute_score(data, opt, rp)
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
            S = compute_rho_scores(pre, opt.maxK);
        else
            error('unexpected value for score');
        end
        
        if opt.edge
            E = compute_edge_scores(data, opt, rp.maxS, pre);
            S = add_edge_scores(S, E, rp.psi);
        end;
        S = prune_scores(S);
        T = toc;   
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [bn_opt, bnet, rp, class_opt, true_Pdag, SHD, T] = ...
            init(network, type, variance, Nvec, num_bnet, num_Nrep, ...
            maxpa, maxS, maxK, psi, plot_flag, save_flag, f_sel)
        
        check_dir();
        rp = struct();
        
        rp.network = network;
        rp.type = type;
        rp.variance = variance;
        rp.Nvec = Nvec;
        rp.num_bnet = num_bnet;
        rp.num_Nrep = num_Nrep;
        rp.maxpa = maxpa;
        rp.maxS = maxS;
        rp.maxK = maxK;
        rp.psi = psi;
        rp.plot_flag = plot_flag;
        rp.save_flag = save_flag;
        rp.f_sel = f_sel;
        
        bn_opt = struct('network', network, 'arity', 1, 'type', type, ...
            'variance', variance, 'moralize', false, 'n', 8);
        [bnet, bn_opt] = make_bnet(bn_opt);

        full_opt = {
            struct('method', 'mmhc', 'arity', 3, 'edge', false, ...
                'color', 'g-'), ...
            struct('method', 'sb3', 'classifier', @kci_classifier, ...
                'kernel', GaussKernel(),  'arity', 1, ...
                'prealloc', @kci_prealloc, 'pval', false, ...
                'edge', true, 'maxK', rp.maxK, 'color', 'm-'), ...
            struct( 'method', 'sb3', 'classifier', @kci_classifier, ...
                'kernel', GaussKernel(),  'arity', 1, ...
                'prealloc', @kci_prealloc, 'pval', true, ...
                'edge', true, 'maxK', rp.maxK, 'color', 'r-'), ...
            struct('method', 'bic','classifier', @sb_classifier, ...
                'params', struct('eta', 0.01, 'alpha', 1.0), ...
                'prealloc', @dummy_prealloc, 'arity', 4, ...
                'edge', false, 'color','b-')};
        class_opt = full_opt(f_sel);
        
        if rp.plot_flag
            figure
        end
        
        for c = 1:length(class_opt)
            o = class_opt{c};
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
            class_opt{c}.name = sprintf('%s%s', o.method, str);
        end
        
        true_Pdag = dag_to_cpdag(get_dag(bn_opt));
        SHD = cell(length(class_opt), 1); % hamming distance
        T = cell(length(class_opt), 1); % runtime
    end

end

