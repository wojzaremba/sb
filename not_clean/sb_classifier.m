function classes = sb_classifier(emp, options)
% returns a binary vector the same length as options.range, with 1
% signifying independence, and 0 dependence
%
% options.range is a set of threshold values

arity = options.arity;
A = enumerate_assignments(size(emp,1)-2,arity);
eta = 0.01;
rho = -Inf;

for t = 1:size(A,1)
    cond_emp = condition_emp(emp,A(t,:));
    counts = cond_emp_to_counts(cond_emp,arity);
    rho = max(rho,compute_sb(counts,eta));
    if (rho == 1)
        break
    end
end

printf(2, 'rho=%d\n',rho);
classes = threshold(options.range,rho);
