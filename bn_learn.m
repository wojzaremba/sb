function [SHD, T1, T2, bn_opt, rp, c_opt, data] = bn_learn(network, arity, ...
    type, variance, Nvec, num_exp, maxS, psi, plot_flag, save_flag, f_sel)

% initialize
[bn_opt, bnet, rp, c_opt, true_Pdag, SHD, T1, T2] = init(network, arity, ...
    type, variance, Nvec, num_exp, maxS, psi, plot_flag, save_flag, f_sel);

for exp = 1:rp.num_exp
    fprintf('exp %d...\n',exp);
    
    for N_idx = 1:length(rp.Nvec)
        % sample and preprocess data
        N = rp.Nvec(N_idx);
        fprintf('N = %d\n', N);
        data = normalize_data(samples(bnet, N));
        data_d = discretize_data(data, rp.arity); 
        
        % learn one structure using each score in c_opt
        for t = 1:length(c_opt)
            opt = c_opt{t};
            fprintf('score = %s, %s sparsity boost\n', opt.score, ...
                repmat('no', ~opt.edge));
            [S, T1{t}(N_idx, exp)] = compute_score(opt);
            [G, T2{t}(N_idx, exp)] = run_gobnilp(S);
            pred_Pdag = dag_to_cpdag(G);
            SHD{t}(N_idx, exp) = shd(true_Pdag,pred_Pdag);
            if ~isequal(true_Pdag, pred_Pdag)
                fprintf('predicted PDAG:\n');
                pred_Pdag
                true_Pdag
            end
            fprintf('hamming distance = %d\n', SHD{t}(N_idx, exp));
        end
    end
    
    
    bnet = make_bnet(bn_opt);
    
    
    if rp.plot_flag
        update_plot(exp);
        pause(2);
    end
end

assert(isequal(size(SHD{1}), [length(rp.Nvec), rp.num_exp]));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    function update_plot(exp)
        clf;
        h1 = [];
        h2 = [];
        leg1 = {};
        leg2 = {};
        for c = 1 : length(c_opt)
            opt = c_opt{c};
            s = repmat('no', ~opt.edge);
            subplot(1, 2, 1)
            hold on
            shd = SHD{c}(:, 1:exp);
            h1(end+1) = plot(rp.Nvec, mean(shd, 2), opt.color, 'linewidth', 2);
            leg1{end+1} = sprintf('%s, %s edge scores', opt.score, s);
            
            subplot(1, 2, 2)
            hold on
            t1 = T1{c}(:, 1:exp);
            t2 = T2{c}(:, 1:exp);
            h2(end+1) = plot(rp.Nvec, mean(t1, 2), opt.color, 'linewidth', 2);
            h2(end+1) = plot(rp.Nvec, mean(t2, 2), [opt.color '-'], 'linewidth', 2);
            leg2{end+1} = sprintf('%s, %s edge, score time', opt.score, s);
            leg2{end+1} = sprintf('%s, %s edge, structure search', opt.score, s);
        end
        
        subplot(1, 2, 1);
        legend(h1, leg1);
        yl = ylim;
        ylim([0 yl(2)]);
        xlabel('number of samples');
        ylabel('structural hamming distance');
        title(sprintf('SHD vs. N, %s network, %d experiments', rp.network, exp), 'fontsize', 14);
        
        subplot(1, 2, 2);
        legend(h2, leg2);
        xlabel('number of samples');
        ylabel('runtime (sec)');
        title(sprintf('Runtime vs. N, %s network, %d experiments', rp.network, exp), 'fontsize', 14);
    end

    function [S, T] = compute_score(opt)
        tic;
        
        % choose discrete or cts data
        if opt.arity > 1
            emp = data_d;
        else
            emp = data;
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
            E = compute_edge_scores(emp, opt, rp.maxS);
            S = add_edge_scores(S, E, rp.psi);
        end;
        S1 = S;
        S = prune_scores(S);
        fprintf('pruning scores changed S? %d\n', isequal(S, S1));
        T = toc;   
    end

    function [bn_opt, bnet, rp, class_opt, true_Pdag, SHD, T1, T2] = ...
            init(network, arity, type, variance, Nvec, num_exp, maxS, ...
            psi, plot_flag, save_flag, f_sel)
        
        check_dir();
        rp = struct();
        
        rp.network = network;
        rp.arity = arity;
        rp.type = type;
        rp.variance = variance;
        rp.Nvec = Nvec;
        rp.num_exp = num_exp;
        rp.maxS = maxS;
        rp.psi = psi;
        rp.plot_flag = plot_flag;
        rp.save_flag = save_flag;
        rp.f_sel = f_sel;
        
        %fprintf('WARNING: bn_opt.arity = 3\n');
        % XXX add check whether type is cts or discrete, change arity to
        % either 1 or rp.arity accordingly
        bn_opt = struct('network', network, 'arity', 1, 'type', type, ...
            'variance', variance, 'moralize', false);
        [bnet, bn_opt] = make_bnet(bn_opt);

        
        full_opt = {struct('classifier', @sb_classifier, 'params', ...
            struct('eta', 0.01, 'alpha', 1.0), 'arity', rp.arity, ...
            'prealloc', @dummy_prealloc, 'score', 'bic', 'edge', false, ...
            'color','b-'), ...
            struct('classifier', @sb_classifier, 'params', ...
            struct('eta', 0.01, 'alpha', 1.0), 'arity', rp.arity, ...
            'prealloc', @dummy_prealloc, 'score', 'bic', 'edge', true, ...
            'color','g-'), ...
            struct( 'classifier', @kci_classifier,'pval', false, ...
            'kernel', GaussKernel(),  'arity', 1, ...
            'prealloc', @kci_prealloc, 'score', 'rho', 'edge', true, ...
            'maxK', 5, 'color', 'm-')};
        class_opt = full_opt(f_sel);
        
        if rp.plot_flag
            figure
        end
        
        true_Pdag = dag_to_cpdag(get_dag(bn_opt));
        SHD = cell(length(class_opt), 1); % hamming distance
        T1 = cell(length(class_opt), 1); % score time
        T2 = cell(length(class_opt), 1); % structure search
        
    end

end

