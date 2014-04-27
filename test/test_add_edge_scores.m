disp('test_add_edge_scores...');

arity = 3;
bnet = mk_bnet4_vstruct(arity);
maxpa = 2;
maxS = 2;
N = 1000;

empty = struct('name', 'none');
opt = struct('classifier', @sb_classifier, 'rho_range', [0 1],...
    'prealloc', @dummy_prealloc, 'kernel', empty,...
    'color', 'm','params',struct('eta',0.01,'alpha',1.0),...
    'normalize',false,'name','bayesian conditional MI', 'arity', arity);

emp = samples(bnet,N);
if opt.normalize
    emp = normalize_data(emp);
end

S = compute_bic(emp, arity, maxpa);
E = compute_edge_scores(emp, opt, maxS);
S2 = add_edge_scores(S, E);