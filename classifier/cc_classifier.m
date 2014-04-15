function rho = cc_classifier(emp, options)
% returns a binary vector the same length as options.range, with 1
% signifying independence, and 0 dependence
%
% options.range is a set of threshold values

    arity = options.arity;
    
    rho = -Inf;
    % for each assignment to the conditioning set, take max(rho,abs(corr))
    A = enumerate_assignments(size(emp,1)-2,arity);
    for t = 1:size(A,1)
        cond_emp = condition_emp(emp,A(t,:));
        %size(cond_emp)
        %isempty(cond_emp)
        if (size(cond_emp,2) > 20)
            rho = max(rho,abs(corr(cond_emp(1,:)',cond_emp(2,:)')));
        else
            rho = 1;
            break
        end
    end
    
    %printf(2, 'rho=%d\n',rho);
    %classes = threshold(options.range,rho);
end
