function S = compute_bic(emp, arity)

maxpa = 3;
nodes = size(emp,1);

% enumerate all subsets up to size maxpa + 1
% for each subset, compute bic score
% later, try to cache
S = cell(nodes, 1); 

for n = 1:(maxpa+1)
    families = combinations(1:nodes,n);
    for f = 1:size(families,1)
        family = families(f,:);
        S = compute_bic_family(S, emp, family, arity);
    end
end
