function [rho, info] = sb_classifier(emp, trip, options, prealloc)
% returns max sparsity boost score over all possible values to the
% conditioning set.  The max sb score (this is before taking -log) is the
% most dependent, hence conservative)
emp = emp(trip,:);
arity = options.arity;
A = enumerate_assignments(size(emp,1)-2,arity);
eta = options.params.eta;
alpha = options.params.alpha;

rho = -Inf*ones(length(eta),length(alpha));
info = struct();

for t = 1:size(A,1)
    cond_emp = condition_emp(emp,A(t,:));
    counts = cond_emp_to_counts(cond_emp,arity);
    [new_rho, new_info] = compute_sb(counts, eta, alpha);
    if new_rho > rho
        rho = new_rho;
        info = new_info;
        info.assignment = A(t,:);
    end
%     if (rho >= 1 - 1e-4)
%         break
%     end
end
