
D = preprocess_sachs_data(false);

arity = 3;
maxpa = 3;
D = discretize_data(D, 3);

tic;
S = compute_bic(D, arity, maxpa);
fprintf('done computing bic\n');
S = prune_scores(S);
score_time = toc;
fprintf('score time = %f\n', score_time);

[G, search_time] = run_gobnilp(S);
fprintf('search time = %f\n', search_time);

%PDAG = dag_to_cpdag(G);

names = {'Raf', 'Mek', 'Plc_g', 'PIP2', 'PIP3', 'Erk', 'Akt', 'PKA', 'PKC', 'P38', 'Jnk'};
g_obj = biograph(G, names);
g_obj = view(g_obj);