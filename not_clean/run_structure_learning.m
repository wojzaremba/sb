function [SHD, T1, T2] = run_structure_learning(network, score, edge, plot_flag)

num_exp = 5;
Nvec = 50:10:70; %50:100; %400;
maxS = 2;
psi = 1;

type = 'quadratic_ggm';
variance = 0.05;

bn_opt = struct('variance', variance, 'network', network, 'arity', 1,... 
'type', type, 'moralize', false);
opt = get_opt(score);
true_Pdag = dag_to_cpdag(get_dag(bn_opt));

SHD = zeros(num_exp, length(Nvec));
T1 = zeros(num_exp, length(Nvec)); % score time
T2 = zeros(num_exp, length(Nvec)); % structure search

[bnet, bn_opt] = make_bnet(bn_opt);
maxpa = bn_opt.maxpa;
for exp = 1:num_exp
    fprintf('exp %d...\n',exp);
    
    for N_idx = 1:length(Nvec)
        % setup
        N = Nvec(N_idx);
        fprintf('N = %d\n', N);
        emp = discretize_data(normalize_data(samples(bnet,N)), opt.arity);
        pre = opt.prealloc(emp, opt);
        
        % compute scores
        tic;
        S = compute_score(score);
        if edge
            E = compute_edge_scores(emp, opt, maxS);
            S = add_edge_scores(S, E, psi);
        end
        S = prune_scores(S);
        T1(exp, N_idx) = toc;
        
        % structure search
        [G, T2(exp, N_idx)] = run_gobnilp(S);
        pred_Pdag = dag_to_cpdag(G);
        SHD(exp,N_idx) = shd(true_Pdag,pred_Pdag); 
        fprintf('hamming distance = %d\n', SHD(exp, N_idx));
    end
    
    bnet = make_bnet(bn_opt);
    
end

%%% plot %%%%%%%%%%
if ~exist('plot_flag')
    plot_flag = false;
end
if plot_flag
    s = repmat('no', edge);
    subplot(1, 2, 1)
    plot(Nvec, mean(SHD, 1), 'b-', 'linewidth', 2);
    xlabel('number of samples');
    ylabel('structural hamming distance');
    title(sprintf('SHD vs. N, %s network, %s edge scores', network, s), 'fontsize', 14);
    
    subplot(1, 2, 2)
    h(1) = plot(Nvec, mean(T1, 1),'r-','linewidth', 2);
    hold on
    h(2) = plot(Nvec, mean(T2, 1), 'b-', 'linewidth', 2);
    xlabel('number of samples');
    ylabel('runtime (sec)');
    title(sprintf('Runtime vs. N, %s network %s edge scores', network, s), 'fontsize', 14);
    legend(h,{'score time', 'structure search'});
end


    function opt = get_opt(score)      
        if strcmpi(score, 'bic')
            opt = struct('classifier', @sb_classifier, 'params', ...
                struct('eta', 0.01, 'alpha', 1.0), 'arity', 3, ...
                'prealloc', @dummy_prealloc, 'score', @compute_bic);
        elseif strcmpi(score, 'rho')
            opt = struct( 'pval', false, 'kernel', GaussKernel(), ...
                'classifier', @kci_classifier, ...
                'prealloc', @kci_prealloc, 'arity', 1);
        else
            error('unexpected value for score');
        end
    end

    function S = compute_score(score)
        maxK = 5;
        if strcmpi(score, 'bic')
            S = compute_bic(emp, opt.arity, maxpa);
        elseif strcmpi(score, 'rho')
            S = compute_rho_scores(pre, maxK);
        else
            error('unexpected value for score');
        end    
    end

end

