function S = compute_bic(emp, arity, maxpa)

nodes = size(emp,1);

% enumerate all subsets up to size maxpa + 1
% for each subset, compute bic score
% later, try to cache
S = cell(nodes, 1); 

% enumerate subsets backwards (largest to smallest) for the purposes of comparing the output of
% bscore
for n = (maxpa+1):-1:1
    families = combinations(1:nodes,n);
    for f = size(families,1):-1:1
        family = families(f,:);
        S = compute_bic_family(S, emp, family, arity);
    end
end
