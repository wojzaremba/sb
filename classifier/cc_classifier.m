function rho = cc_classifier(emp, trip, options)
% returns maximum absolute correlation over all assignments to conditioning
% set
    emp = emp(trip,:);
    arity = options.arity;
    
    rho = -Inf;
    A = enumerate_assignments(size(emp,1)-2,arity);
    for t = 1:size(A,1)
        cond_emp = condition_emp(emp,A(t,:));
        if (size(cond_emp,2) > 10)
            rho = max(rho,abs(corr(cond_emp(1,:)',cond_emp(2,:)')));
        else
            rho = 1;
            break
        end
    end
end
