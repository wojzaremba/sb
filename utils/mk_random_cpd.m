function cpd = mk_random_cpd(arity,dim)
% generate a CPD (i.e. discrete distribution over last dimension
% conditioned on all other states of variables corresponding to the other
% dimensions)
% For example, arity=5, dim=2 will make a 5-by-5 array, where
% sum(cpd(i,:)) = 1 for each i in 1,..,5.

cpd = abs(randn(arity*ones(1,dim)));
A = enumerate_assignments(dim-1,arity);

for t = 1:size(A,1)
    idx = num2cell(A(t,:));
    cpd(idx{:},:) = cpd(idx{:},:) / sum(cpd(idx{:},:)) ;
end
