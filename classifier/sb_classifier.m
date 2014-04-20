function rho = sb_classifier(emp, options)
% returns max sparsity boost score over all possible values to the
% conditioning set.  The max sb score (this is before taking -log) is the
% most dependent, hence conservative)

arity = options.arity;
A = enumerate_assignments(size(emp,1)-2,arity);
eta = options.params.eta;
alpha = options.params.alpha;

rho = -Inf*ones(length(eta),length(alpha));

for t = 1:size(A,1)
    cond_emp = condition_emp(emp,A(t,:));
    counts = cond_emp_to_counts(cond_emp,arity);
    rho = max(rho,compute_sb(counts,eta,alpha));
    if (rho == 1)
        break
    end
end

% printf(2, 'rho=%d\n',rho);
% classes = threshold(options.range,rho);
