function [G_sb, G, PDAG_sb, PDAG, S_sb, S] = sachs_learn_multi()

for i = 1 : 10
    [G_sb{i}, PDAG_sb{i}, S_sb{i}] = sachs_learn(i, true);
    [G{i}, PDAG{i}, S{i}] = sachs_learn(i, false);
end

end

function [G,PDAG,S] = sachs_learn(subset, edge)

% load data
load sachs
D = X([1:1200 3601:5400], :)';

arity = 3;
opt = struct('classifier', @sb_classifier, 'params',struct('eta',0.01,'alpha',1.0),'arity', arity, 'prealloc', @dummy_prealloc);
maxpa = 3;
maxS = 2;

tic;
D = sachs_subset(D, subset);

S = compute_bic(D, arity, maxpa);
fprintf('done computing BIC\n');
if edge
    E = compute_edge_scores(D, opt, maxS);
    fprintf('done computing edge scores\n');
    S = add_edge_scores(S, E);
end
S = prune_scores(S);
score_time = toc;
fprintf('score time = %f\n', score_time);

[G, search_time] = run_gobnilp(S);
fprintf('search time = %f\n', search_time);

PDAG = dag_to_cpdag(G);
%h = plot_sachs(pdag);

end

function Dnew = sachs_subset(D, subset)

folds = 10;

Dnew = [];

C{1} = D(:, 1:600);
C{2} = D(:, 601:1200);
C{3} = D(:, 1201:1800);
C{4} = D(:, 1801:2400);
C{5} = D(:, 2401:3000);

for i = 1 : 5
   c = C{i};
   Dnew = [Dnew c(:, 1:(600/folds)*subset)];
end

end