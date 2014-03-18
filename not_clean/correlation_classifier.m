function ret = correlation_classifier(emp, options)
% ret = 0 means that variables described by emp are independent.
% ret = 1 means that variables are dependent.
    ret = 0;
    emp_cpd = emp_to_cpd(emp, options.arity);
    threshold = options.threshold;
    emp_cpd = emp_cpd(:, :, :);
    
    for t = 1:size(emp_cpd, 3)
        if (correlation(emp_cpd(:, :, t)) > threshold)
            ret = 1;
            return;
        end
    end    
end