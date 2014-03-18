% clear all;
bnet = mk_bnet4();
K = length(bnet.dag);
arity = get_arity(bnet);

max_S = 2;
triples = gen_triples(K,max_S);

N = 1000;
s = samples(bnet,N);

range = 10 .^ [-3:.5:-1, 1];
classifiers = {@correlation_classifier, @mutual_information_classifier};

for c = 1:length(classifiers)
    scores = zeros(2, 2, length(range));
    w_acc = zeros(length(range), 1);
    for i = 1:length(range)
        fprintf('Starting i = %f\n', range(i));
        options = struct('threshold', range(i), 'arity', arity);
        for t = 1 : length(triples)        
            indep = double(dsep(triples{t}(1), triples{t}(2), triples{t}(3:end), bnet.dag));
            emp = s(triples{t}, :);
            indep_emp = double(classifiers{c}(emp, options));       
            scores(1 + indep, indep_emp + 1, i) = scores(1 + indep, indep_emp + 1, i) + 1;
        end
        P = scores(2, 1, i) + scores(2, 2, i);
        N = scores(1, 2, i) + scores(1, 1, i);
        TP = scores(2, 2, i);        
        TN = scores(1, 1, i);
        % XXX check whether we need to flip FN and FP
        FN = scores(2,1,i);
        FP = scores(1,2,i); 
        w_acc(i) = (TP / P + TN / N) / 2;
    end
    fprintf('func = %s, max(w_acc) = %f\n', func2str(classifiers{c}), max(w_acc));
    plot(w_acc);
    title(sprintf('%s', funcstr(classifers{c})));
    hold on;
end