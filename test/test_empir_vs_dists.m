function test_empir_vs_dists()
    disp('test_empir_vs_dists...');
    rand('seed',1);
    bnet = mk_bnet4();
    K = length(bnet.dag);
    arity = get_arity(bnet);
    
    max_S = 2;
    triples = gen_triples(K,max_S);

    N = 2000;
    s = samples(bnet,N);

    for t = 1 : length(triples)
        for c = 1:length(triples{t}.cond_set)
            tri = [triples{t}.i triples{t}.j triples{t}.cond_set{c}];
            D = get_marginal_dist(tri,bnet);
            emp = s(tri, :);
            emp_dist = emp_to_dist(emp,arity);
            assert(norm(D(:) - emp_dist(:)) < 0.2);
        end
    end
end
