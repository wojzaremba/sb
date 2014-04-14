function test_empir_vs_dists()
    disp('test_empir_vs_dists...');
    bnet = mk_bnet4();
    K = length(bnet.dag);
    arity = get_arity(bnet);
    
    max_S = 2;
    triples = gen_triples(K,max_S);

    N = 10000;
    s = samples(bnet,N);

    for t = 1 : length(triples)
        D = get_marginal_dist(triples{t},bnet);
        emp = s(triples{t}, :);
        emp_dist = emp_to_dist(emp,arity);
        assert(norm(D(:) - emp_dist(:)) < 0.1);
    end
end
