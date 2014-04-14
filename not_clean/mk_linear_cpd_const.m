function cpd = mk_linear_cpd_const(arity,dim)

% generate a CPD (i.e. discrete distribution over last dimension
% conditioned on all other states of variables corresponding to the other
% dimensions)
% For example, arity=5, dim=2 will make a 5-by-5 array, where
% sum(cpd(i,:)) = 1 for each i in 1,..,5.
% put 90% of probability mass on the diagonal, 10% off diagonal, uniform

cpd = ones(arity*ones(1,dim)) / (10*(arity-1));

for a = 1:arity
    idx = num2cell(a*ones(1,dim));
    cpd(idx{:},:) = 0.9;
end

% A = enumerate_assignments(dim-1,arity);
% 
% for t = 1:size(A,1)
%     idx = num2cell(A(t,:));
%     cpd(idx{:},:) =  ;
% end


