function rho = cc_classifier(emp, trip, options, prealloc)
% returns either maximum absolute correlation over all assignments to
% conditioning set, or a weighted mean
    
emp = emp(trip,:);
arity = options.arity;
check = false;
if ( isfield(options, 'check_counts') && options.check_counts )
    check = true;
end

A = enumerate_assignments(size(emp,1)-2,arity);

rho = 0;
for t = 1:size(A,1)
    cond_emp = condition_emp(emp,A(t,:));
    if ~isempty(cond_emp)
        if (check && size(cond_emp,2) <= 10)
            rho = 1;
            break;
        else
            % take weakest evidence for independence
            rho = max(rho,abs(my_corr(cond_emp(1,:)',cond_emp(2,:)')));
        end
    else
        printf(2,'cond_emp is empty');
    end
    if (rho >= 1 - 1e-4)
        break
    end
end
assert((0 <= rho) && (rho <= 1));

end




