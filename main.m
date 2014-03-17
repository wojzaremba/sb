bnet = mk_bnet4();
K = length(bnet.dag);
arity = get_arity(bnet);

max_S = 2;
triples = gen_triples(K,max_S);

N = 10000;
s = samples(bnet,N);

options = struct('threshold', 0.1, 'arity', arity);
score = zeros(2, 2);
for t = 1 : length(triples)        
    indep = dsep(triples{t}(1), triples{t}(2), triples{t}(3:end), bnet.dag);
    emp = s(triples{t}, :);
    result = mutual_information_classifier(emp, options); 
    score(indep + 1, result + 1) = score(indep + 1, result + 1) + 1;
end
