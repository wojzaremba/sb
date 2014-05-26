function [SHD, T1, T2, bn_opt, rp, c_opt, data] = bn_learn(network, ...
    type, variance, Nvec, num_bnet, num_Nrep, maxS, psi, plot_flag, ...
    save_flag, f_sel)

% initialize
[bn_opt, bnet, rp, c_opt, true_Pdag, SHD, T1, T2] = init(network, ...
    type, variance, Nvec, num_bnet, num_Nrep, maxS, psi, plot_flag, ...
    save_flag, f_sel);

for bn = 1:rp.num_bnet       
    for Nrep = 1:rp.num_Nrep
        for N_idx = 1:length(rp.Nvec)
            N = rp.Nvec(N_idx);
            data = normalize_data(samples(bnet, N));
            for t = 1:length(c_opt)
                opt = c_opt{t};
                fprintf('bn %d, N=%d, %s...\n', bn, N, opt.name);
                emp = discretize_data(data, opt.arity);
                [S, T1{t}(bn, Nrep, N_idx)] = compute_score(opt);
                [G, T2{t}(bn, Nrep, N_idx)] = run_gobnilp(S);
                SHD{t}(bn, Nrep, N_idx) = compute_shd(G);
            end
        end  
        if rp.plot_flag
            update_plot(bn, Nrep);
            pause(2);
        end
    end
    bnet = make_bnet(bn_opt);
end
assert(isequal(size(SHD{1}), [rp.num_bnet rp.num_Nrep length(rp.Nvec)]));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function SHD = compute_shd(G)
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
    function update_plot(bn, Nrep)
        clf;
        h1 = [];
        h2 = [];
        leg1 = {};
        leg2 = {};
        for c = 1 : length(c_opt)
            opt = c_opt{c};
            c1 = [opt.color '-'];
            c2 = [opt.color '--'];
            subplot(1, 2, 1); hold on
            shd = SHD{c}(1:bn, 1:Nrep, :);
            h1(end+1) = plot(rp.Nvec, squeeze(mean(mean(shd, 1), 2)), c1, 'linewidth', 2);
            leg1{end+1} = opt.name;
            
            subplot(1, 2, 2); hold on
            t1 = T1{c}(1:bn, 1:Nrep, :);
            t2 = T2{c}(1:bn, 1:Nrep, :);
            h2(end+1) = plot(rp.Nvec, squeeze(mean(mean(t1, 1), 2)), c1, 'linewidth', 2);
            h2(end+1) = plot(rp.Nvec, squeeze(mean(mean(t2, 1), 2)), c2, 'linewidth', 2);
            leg2{end+1} = sprintf('%s, score time', opt.name);
            leg2{end+1} = sprintf('%s, structure search', opt.name);
        end
        
        subplot(1, 2, 1);
        legend(h1, leg1);
        yl = ylim;
        ylim([0 yl(2)]);
        xlabel('number of samples');
        ylabel('structural hamming distance');
        title(sprintf('SHD vs. N, %s network, %d parameter settings, %d reps', rp.network, bn, Nrep), 'fontsize', 14);
        
        subplot(1, 2, 2);
        legend(h2, leg2);
        xlabel('number of samples');
        ylabel('runtime (sec)');
        title(sprintf('Runtime vs. N, %s network, %d parameter settings, %d reps', rp.network, bn, Nrep), 'fontsize', 14);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [S, T] = compute_score(opt)
        tic;
        
        if ~opt.edge
            if isfield(opt, 'pval')
                opt.pval = false;
            end
        end
               
        % preallocate
        pre = opt.prealloc(emp, opt);
        
        % compute base scores
        if strcmpi(opt.score, 'bic')
            S = compute_bic(emp, opt.arity, bn_opt.maxpa);
        elseif strcmpi(opt.score, 'rho')
            S = compute_rho_scores(pre, opt.maxK);
        else
            error('unexpected value for score');
        end
        
        if opt.edge
            E = compute_edge_scores(emp, opt, rp.maxS, pre);
            S = add_edge_scores(S, E, rp.psi);
        end;
        S = prune_scores(S);
        T = toc;   
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [bn_opt, bnet, rp, class_opt, true_Pdag, SHD, T1, T2] = ...
            init(network, type, variance, Nvec, num_bnet, num_Nrep, maxS, ...
            psi, plot_flag, save_flag, f_sel)
        
        check_dir();
        rp = struct();
        
        rp.network = network;
        rp.type = type;
        rp.variance = variance;
        rp.Nvec = Nvec;
        rp.num_bnet = num_bnet;
        rp.num_Nrep = num_Nrep;
        rp.maxS = maxS;
        rp.psi = psi;
        rp.plot_flag = plot_flag;
        rp.save_flag = save_flag;
        rp.f_sel = f_sel;
        
        bn_opt = struct('network', network, 'arity', 1, 'type', type, ...
            'variance', variance, 'moralize', false, 'n', 8);
        [bnet, bn_opt] = make_bnet(bn_opt);

        
        full_opt = {struct('classifier', @sb_classifier, 'params', ...
            struct('eta', 0.01, 'alpha', 1.0), 'arity', 4, ...
            'prealloc', @dummy_prealloc, 'score', 'bic', 'edge', false, ...
            'color','b'), ...
            struct('classifier', @sb_classifier, 'params', ...
            struct('eta', 0.01, 'alpha', 1.0), 'arity', 4, ...
            'prealloc', @dummy_prealloc, 'score', 'bic', 'edge', true, ...
            'color','g'), ...
            struct( 'classifier', @kci_classifier,'pval', false, ...
            'kernel', GaussKernel(),  'arity', 1, ...
            'prealloc', @kci_prealloc, 'score', 'rho', 'edge', true, ...
            'maxK', 5, 'color', 'm'), ...
            struct( 'classifier', @kci_classifier,'pval', true, ...
            'kernel', GaussKernel(),  'arity', 1, ...
            'prealloc', @kci_prealloc, 'score', 'rho', 'edge', true, ...
            'maxK', 5, 'color', 'r')};
        class_opt = full_opt(f_sel);
        
        if rp.plot_flag
            figure
        end
        
        for c = 1:length(class_opt)
            opt = class_opt{c};
            class_opt{c}.name = sprintf('%s, %s edge, arity %d, %s pval', ...
                opt.score, repmat('no', ~opt.edge), opt.arity, repmat('no', ~opt.pval));
        end
        
        true_Pdag = dag_to_cpdag(get_dag(bn_opt));
        SHD = cell(length(class_opt), 1); % hamming distance
        T1 = cell(length(class_opt), 1); % score time
        T2 = cell(length(class_opt), 1); % structure search
    end

end

