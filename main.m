bnet = mk_bnet4();
K = length(bnet.dag);

triples = gen_triples(K, 2);

N = 1000;
s = samples(bnet,N);

for t = 1 : length(triples)
    cpd = get_cpd(triples{t},bnet);
    indep = dsep(triples{t}(1), triples{t}(2), triples{t}(3:end), bnet.dag);
    emp = s(triples{t}, :);
    emp_cpd = emp_to_cpd(emp);
    
end