function test_empir_vs_cpds()
    bnet = mk_bnet4();
    K = length(bnet.dag);
    arity = get_arity(bnet);
    
    max_S = 2;
    triples = gen_triples(K,max_S);

    N = 10000;
    s = samples(bnet,N);

    for t = 1 : length(triples)
        %fprintf('t=%d\n',t);
        cpd = get_cpd(triples{t},bnet);
%         indep = dsep(triples{t}(1), triples{t}(2), triples{t}(3:end), bnet.dag);
        emp = s(triples{t}, :);
        emp_cpd = emp_to_cpd(emp,arity);
        assert(norm(cpd(:) - emp_cpd(:)) < 0.1);
    end
end