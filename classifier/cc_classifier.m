function rho = cc_classifier(emp, trip, options, prealloc)
% returns either maximum absolute correlation over all assignments to
% conditioning set, or a weighted mean

    emp = emp(trip,:);
    arity = options.arity;
    
    A = enumerate_assignments(size(emp,1)-2,arity);
    n = NaN*ones(size(A,1),1);
    
    if strcmpi(options.aggregation, 'min')
        rho = -Inf;
        for t = 1:size(A,1)
            cond_emp = condition_emp(emp,A(t,:));
            if ~isempty(cond_emp)
                % take weakest evidence for independence
                rho = max(rho,abs(my_corr(cond_emp(1,:)',cond_emp(2,:)')));
            else
                printf(2,'cond_emp is empty');
            end
            if (abs(rho - options.rho_range(2)) < 1e-4)
                break
            end
        end
    elseif strcmpi(options.aggregation, 'mean')
        rho = NaN*ones(size(A,1),1);
        for t = 1:size(A,1)
            cond_emp = condition_emp(emp,A(t,:));
            if ~isempty(cond_emp)
                rho(t) = abs(my_corr(cond_emp(1,:)',cond_emp(2,:)'));
            else
                rho(t) = 0;
            end
            n(t) = size(cond_emp, 2);
        end
        assert(sum(n) == size(emp, 2));
        rho = (rho'*n) / sum(n);
    else
        error('unexpected value in options.aggregation.');
    end
end



