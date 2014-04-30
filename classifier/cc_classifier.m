function rho = cc_classifier(emp, trip, options, prealloc)
% returns either maximum absolute correlation over all assignments to
% conditioning set, or a weighted mean
    
    emp = emp(trip,:);
    arity = options.arity;
    
    A = enumerate_assignments(size(emp,1)-2,arity);

        rho = 0;
        for t = 1:size(A,1)
            cond_emp = condition_emp(emp,A(t,:));
            if ~isempty(cond_emp)
                % take weakest evidence for independence
                rho = max(rho,abs(my_corr(cond_emp(1,:)',cond_emp(2,:)')));
            else
                printf(2,'cond_emp is empty');
            end
            if (rho >= 1 - 1e-4)
                break
            end
        end
        assert((0 <= rho) && (rho <= 1));
    
end



