function cpd = normalize_cpd(cpd)
% normalize so that the last dimension sums to 1

dim = length(size(cpd));
arity = size(cpd,1); % assume same arity for all variables
A = enumerate_assignments(dim-1,arity);

for t = 1:size(A,1)
    idx = num2cell(A(t,:));
    cpd(idx{:},:) = cpd(idx{:},:) / sum(cpd(idx{:},:));
end