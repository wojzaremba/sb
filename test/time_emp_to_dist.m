function time_emp_to_dist()

bnet = mk_bnet4();
K = length(bnet.dag);
arity = get_arity(bnet);

triples = gen_triples(K, 2);

N = 1000;
s = samples(bnet,N);
emp = s(triples{end}.cond_set{end}, :);




for t = 1:10000
    emp_to_dist(emp,arity);
end