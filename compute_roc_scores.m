function [scores, rp] = compute_roc_scores(bn_opt, rp)

global debug
debug = 1;

options = get_options(rp);
num_classifiers = length(options);
dag = get_dag(bn_opt.network);
triples = gen_triples(length(dag), rp.maxS);
[no_edge, rp] = get_no_edge(dag, triples, rp);
time_classifier = zeros(1, num_classifiers);

for c = 1 : num_classifiers
    scores{c} = zeros([2 2 length(options{c}.thresholds)]);
end

for exp = 1 : rp.num_exp
    rp.exp = exp;
    fprintf('Experiment #%d, sampling from bayes net...\n', exp);
    bnet = make_bnet(bn_opt);
    s = samples(bnet, rp.N);
    s = normalize_data(s); 
    s_disc = discretize_data(s, rp.arity);
    fprintf('... done.\n');

    for c = 1 : num_classifiers
        tic;
        opt = options{c};
        opt.arity = rp.arity;
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
            scores{c}(1 + no_edge(t),1,:) = scores{c}(1 + no_edge(t),1,:) + ~indep_emp;
            scores{c}(1 + no_edge(t),2,:) = scores{c}(1 + no_edge(t),2,:) + indep_emp;               
        end
        time = toc;
        time_classifier(c) = time_classifier(c) + time;
        fprintf('\tFinished %s, time = %d seconds.\n', opt.name,time);
    end   
    
    if rp.plot_flag
        clf 
        plot_roc(scores, options, rp);
        pause(0.5);
    end
    
    eval(rp.mat_file_command);
    fprintf('Finished exp %d.\n',exp);
end

fprintf('Total running time for all experiments is %d seconds.\n',sum(time_classifier));

end

%%%%%%%%%%%%%%%%%

function [no_edge, rp] = get_no_edge(dag, triples, rp)
% label each pair of variables according to whether there is an edge
% between them
    no_edge = zeros(length(triples),1);
    fprintf('Computing ground truth existence of edges...\n');
    for t = 1 : length(triples)
        i = triples{t}.i;
        j = triples{t}.j;
        no_edge(t) = ~(dag(i,j) || dag(j,i));
    end
    num_edge = length(no_edge) - length(find(no_edge));
    fprintf('Generated %d no-edge and %d edge distributions.\n',length(find(no_edge)),num_edge);  
    
    rp.num_edge = num_edge;
    rp.num_no_edge = length(find(no_edge));
end

function options = get_options(rp)
    arity = rp.arity;
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

    if isfield(rp, 'f_sel')
        options = full_options(rp.f_sel);
    else
        options = full_options;
    end
    
end
