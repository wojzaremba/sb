function test_empir_vs_cpds()
    disp('test_empir_vs_cpds...');
    bnet = mk_bnet4();
    K = length(bnet.dag);
    arity = get_arity(bnet);
    
    max_S = 2;
    triples = gen_triples(K,max_S);

    N = 10000;
    s = samples(bnet,N);

    for t = 1 : length(triples)
        cpd = get_cpd(triples{t},bnet);
        emp = s(triples{t}, :);
        emp_cpd = emp_to_cpd(emp,arity);
        assert(norm(cpd(:) - emp_cpd(:)) < 0.1);
    end
end