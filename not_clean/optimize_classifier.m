clear all;
global debug
debug = 0;
close all;
bnet = mk_asia_large_arity(5);
K = length(bnet.dag);
arity = get_arity(bnet);

max_S = 2;
triples = gen_triples(K, max_S);

num_experiments = 30;
num_samples = 200;

step_size = 1e-4;
range = 0:step_size:1;  
options = {struct('classifier', @sb_classifier, 'kernel', @empty,'range',range, 'color', 'm','params',struct('eta',0.01,'alpha',1))};

num_classifiers = length(options);
name = cell(1,num_classifiers);
TPR = cell(1,num_classifiers);
FPR = cell(1,num_classifiers);
w_acc = cell(1,num_classifiers);

% label each CPD as either independent (1) or dependent (0)
indep = zeros(length(triples), 1);
fprintf('Computing ground truth indep.\n');
for t = 1 : length(triples)
    i = triples{t}(1);
    j = triples{t}(2);
    indep(t) = double(dsep(i, j, triples{t}(3:end), bnet.dag));
    edge(t) = (bnet.dag(i,j) || bnet.dag(j,i));
end
num_indep = length(find(indep));
fprintf('Testing %d independent and %d dependent CPDs, arity=%d, edges=%d\n',num_indep,length(indep)-num_indep,arity,length(find(edge)));

% allocate
for c = 1:num_classifiers
    o = options{c};
    name{c} = sprintf('%s, kernel = %s', func2str(o.classifier), func2str(o.kernel));
    name{c} = strrep(name{c}, '_', ' ');
    num_thresholds = length(o.range);
    w_acc{c} = zeros(1,num_experiments);
    TPR{c} = zeros(num_experiments,num_thresholds);
    FPR{c} = zeros(num_experiments,num_thresholds);
end

for exp = 1:num_experiments
    
    fprintf('Experiment #%d, sampling from bayes net.\n',exp);
    s = samples(bnet, num_samples);
    seconds = 0;
    for c = 1:num_classifiers
        tic;
        o = options{c};

        opt = struct('arity', arity, 'kernel', o.kernel,'range', o.range,'params',o.params);
        
        % allocate
        classes = zeros(size(o.range));
        num_thresholds = length(o.range);
        scores = zeros(2,2,num_thresholds);
        
        % apply classifier
        for t = 1 : length(triples)
            emp = s(triples{t}, :);
            
            % evaluate classifier at all thresholds in range
            indep_emp = o.classifier(emp, opt);
            
            % increment scores accordingly
            for i = 1:length(indep_emp)
                scores(1 + indep(t),indep_emp(i)+1,i) = scores(1 + indep(t),indep_emp(i)+1,i) + 1;
            end
        end
        
        % evaluate
        for r = 1 : num_thresholds
            P = scores(2, 1, r) + scores(2, 2, r);
            N = scores(1, 1, r) + scores(1, 2, r);
            TP = scores(2, 2, r);
            TN = scores(1, 1, r);
            %       FN = scores(2, 1, r);
            FP = scores(1, 2, r);
            TPR{c}(exp,r) = TP/P; % = TP / (TP + FN)
            FPR{c}(exp,r) =  FP/N; % = FP / (FP + TN);
            w_acc{c}(exp) = max(w_acc{c}(exp),(TP / P + TN / N) / 2);
        end
        
        % Assumes that we picked the best threshold.
        %     for i = 1:num_thresholds
        %         r = o.range(i);
        %         acc = (sum((rho{c} < r) .* indep) / sum(indep) + sum((rho{c} >= r) .* (1 - indep)) / sum(1 - indep)) / 2;
        %         w_acc(c) = max(w_acc(c), acc);
        %     end
        seconds_exp = toc;
        seconds = seconds + seconds_exp;
        fprintf('   Finished classifier %s, w_acc=%d, time = %d seconds.\n',name{c},w_acc{c}(exp),seconds_exp);
    end
    fprintf('Total time for experiment %d is %d\n',exp,seconds);

end