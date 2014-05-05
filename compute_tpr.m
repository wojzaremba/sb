function [TPR, FPR, runtime_params] = compute_tpr(network, arity, type, variance, N, num_exp, max_S)
global debug
debug = 0;
%close all;
[bnet, cpd_type, mat_file_command] = init_main(network, arity, type, variance, N);

full_options = get_options(arity);
options = full_options([2 4 5 6]);
num_classifiers = length(options);
TPR = cell(num_classifiers, 1);
FPR = cell(num_classifiers, 1);

triples = gen_triples(length(bnet.dag), max_S);
no_edge = get_no_edge(bnet, triples);

total_time = 0;
for exp = 1 : num_exp
    time_exp = 0;
    fprintf('Experiment #%d, N=%d, sampling from bayes net...\n',exp,N);
    s = samples(bnet, N);
    fprintf('... done.\n');
    s = normalize_data(s); 
    s_disc = discretize_data(s, arity);

    for c = 1 : num_classifiers
        tic;
        opt = options{c};
        opt.arity = arity;
        num_thresholds = length(opt.thresholds);
        scores = zeros([2 2 num_thresholds]);
        if opt.discretize
            emp = s_disc;
        else
            emp = s;
        end            
        % Apply classifier.
        prealloc = opt.prealloc(emp, opt);
        for t = 1 : length(triples)                
            % Evaluate classifier at all thresholds in thresholds.
            rho = classifier_wrapper(emp, triples{t}, opt.classifier, opt, prealloc);
            indep_emp = threshold(opt.thresholds,rho);
            indep_emp = reshape(indep_emp,[1 1 size(indep_emp)]);                
            scores(1 + no_edge(t),1,:) = scores(1 + no_edge(t),1,:) + ~indep_emp;
            scores(1 + no_edge(t),2,:) = scores(1 + no_edge(t),2,:) + indep_emp;               
        end
        [TPR{c}(exp, :), FPR{c}(exp, :)] = scores_to_tpr(scores);            
        time_classifier(c) = toc;
        fprintf('\tFinished %s, time = %d seconds.\n', opt.name,time_classifier(c));
    end
    fprintf('Time for experiment %d, N=%d is %d\n',exp,N);    
    clf
    plot_roc_multi();    
    time_exp = time_exp + sum(time_classifier);
    fprintf('Total time for experiment %d is %d\n', exp, time_exp);
    total_time = total_time + time_exp;
    eval(mat_file_command);
end
fprintf('Total running time for all experiments is %d seconds.\n',total_time);
diary off
end

function [TPR, FPR] = scores_to_tpr(scores)    
    P = scores(2, 1, :) + scores(2, 2, :);
    N = scores(1, 1, :) + scores(1, 2, :);
    TP = scores(2, 2, :);
    FP = scores(1, 2, :);
    TPR = squeeze(TP ./ P);
    FPR =  squeeze(FP ./ N);
end

function [bnet, cpd_type, mat_file_command] = init_main(network, arity, type, variance, N)    
    bn_opt = struct('network', network, 'arity', 1, 'type', type, 'variance', variance);
    cpd_type = strtok(type, '_');
    bnet = make_bnet(bn_opt);

    file_name = sprintf('%s_%s_arity%d_N%d',network, cpd_type, arity, N);
    dir_name = sprintf('results/2014_04_30/%s', file_name);
    system( ['mkdir -p ' dir_name]);
    mat_file_command = sprintf('save %s/%s.mat', dir_name, file_name);
    diary(sprintf('%s/%s.out', dir_name, file_name));
    fprintf('Will %s\n', mat_file_command);
end

function no_edge = get_no_edge(bnet, triples)
% label each pair of variables according to whether there is an edge
% between them
    no_edge = zeros(length(triples),1);
    fprintf('Computing ground truth existence of edges...\n');
    for t = 1 : length(triples)
        i = triples{t}.i;
        j = triples{t}.j;
        no_edge(t) = ~(bnet.dag(i,j) || bnet.dag(j,i));
    end
    num_edge = length(no_edge) - length(find(no_edge));
    fprintf('Generated %d no-edge and %d edge distributions.\n',length(find(no_edge)),num_edge);    
end

function full_options = get_options(arity)
    empty = struct('name', 'none');
    L = LinearKernel();
    G = GaussKernel();
    thresholds = 0:1e-3:1;
    thresholds_mi = 0:1e-3:log2(arity);
    full_options = {struct('classifier', @kci_classifier, 'discretize',false,...
    'prealloc', @kci_prealloc, 'kernel', L,'thresholds', thresholds, ...
    'color', 'g-' ,'params',[],'normalize',true,'name','partial corr, cts data'), ...
    
    struct('classifier', @kci_classifier, 'discretize', false, ...
    'prealloc', @kci_prealloc, 'kernel', G, 'thresholds', thresholds, ...
    'color', 'b-','params',[],'normalize',true,'name','KCI gauss kernel, cts data'), ...
    
    struct('classifier', @kci_classifier, 'discretize',true, ...
    'prealloc', @kci_prealloc, 'kernel', L,'thresholds', thresholds, ...
    'color', 'g--' ,'params',[],'normalize',true,'name',sprintf('partial corr, arity=%d',arity)), ...
    
    struct('classifier', @kci_classifier,'discretize',true,...
    'prealloc', @kci_prealloc, 'kernel', G, 'thresholds', thresholds, ...
    'color', 'b--','params',[],'normalize',true,'name',sprintf('KCI gauss kernel, arity=%d',arity)), ...
    
    struct('classifier', @cc_classifier, 'discretize',true, ...
    'prealloc', @dummy_prealloc, 'kernel', empty, 'thresholds', thresholds, ...
    'color', 'r:','params',[],'normalize',false,'name',sprintf('cond corr, arity=%d',arity)), ...
    
    struct('classifier', @mi_classifier,'discretize',true, ...
    'prealloc', @dummy_prealloc, 'kernel', empty, 'thresholds', thresholds_mi, ...
    'color', 'm-.','params',[],'normalize',false,'name',sprintf('cond MI, arity=%d',arity))};
end
