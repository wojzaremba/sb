function indep = correlation_classifier(emp, options)
% indep = 1 means that variables described by emp are independent.
% indep = 0 means that variables are dependent.
    indep = 1;
    emp_cpd = emp_to_cpd(emp, options.arity);
    threshold = options.threshold;
    emp_cpd = emp_cpd(:, :, :);
    
    %XXX fix this
    for t = 1:size(emp_cpd, 3)
        if (compute_correlation(emp() > threshold)
            indep = 0;
            return;
        end
    end    
end