function rho = cc_classifier(emp, trip, options, prealloc)
% returns maximum absolute correlation over all assignments to conditioning
% set
    emp = emp(trip,:);
    arity = options.arity;
    
    rho = -Inf;
    A = enumerate_assignments(size(emp,1)-2,arity);
    for t = 1:size(A,1)
        cond_emp = condition_emp(emp,A(t,:));
        rho = max(rho,abs(my_corr(cond_emp(1,:)',cond_emp(2,:)')));
        if (abs(rho - options.rho_range(2)) < 1e-4)
            break
        end
    end
end
