function [scores, rp] = compute_roc_scores(rp, options, dag, data, E)

num_classifiers = length(options);
triples = gen_triples(length(dag), 0:rp.maxS);
[no_edge, rp] = get_no_edge(dag, triples, rp);
time_classifier = zeros(1, num_classifiers);

scores = cell(num_classifiers, 1);
for c = 1 : num_classifiers
    scores{c} = zeros([2 2 length(options{c}.thresholds)]);
end

for exp = 1 : rp.num_exp
    rp.exp = exp;
    fprintf('Experiment #%d,\n', exp);
    
    s = data{exp};
    s_disc = discretize_data(s, rp.arity);

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
            if strcmpi(opt.name, 'pval dist') % hack cough hack hack 
                e = E{exp};
                rho = -e(triples{t}.i, triples{t}.j);
            else
                % Evaluate classifier at all thresholds in thresholds.
                rho = classifier_wrapper(emp, triples{t}, opt.classifier, opt, prealloc);
            end
            indep_emp = threshold(opt.thresholds, rho);
            indep_emp = reshape(indep_emp, [1 1 size(indep_emp)]);                
            scores{c}(1 + no_edge(t), 1, :) = scores{c}(1 + no_edge(t),1,:) + ~indep_emp;
            scores{c}(1 + no_edge(t), 2, :) = scores{c}(1 + no_edge(t),2,:) + indep_emp;               
        end
        time = toc;
        time_classifier(c) = time_classifier(c) + time;
        fprintf('\tFinished %s, time = %d seconds.\n', opt.name, time);
    end   
    
    if rp.plot_flag
        clf 
        plot_roc(scores, options);
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

