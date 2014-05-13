function [rho, info] = cc_classifier(emp, trip, options, prealloc)
% returns either maximum absolute correlation over all assignments to
% conditioning set, or a weighted mean
    
emp = emp(trip,:);
arity = options.arity;
check_counts = false;
A = enumerate_assignments(size(emp,1)-2,arity);
rho = 0;
info = struct('low_counts', false, 'check_counts', check_counts, 'empty', false);

for t = 1:size(A,1)
    cond_emp = condition_emp(emp,A(t,:));
    if ~isempty(cond_emp)
        if (check_counts && size(cond_emp,2) <= 10)
            rho = 1;
            info.low_counts = true;
            break;
        else
            % take weakest evidence for independence
            new_rho = abs(my_corr(cond_emp(1,:)',cond_emp(2,:)'));
            if new_rho > rho
                rho = new_rho;
                info.assignment = A(t,:);
            end
        end
    else
        info.empty = true;
        printf(2,'cond_emp is empty');
    end
    if (rho >= 1 - 1e-4)
        break
    end
end
assert((0 <= rho) && (rho <= 1));

end




