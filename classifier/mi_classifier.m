function rho = mutual_information_classifier(emp, options)
    emp_cpd = emp_to_cpd(emp, options.arity);
    emp_cpd = emp_cpd(:, :, :);
    rho = -Inf;
    for t = 1:size(emp_cpd, 3)
        rho = max(rho, mutual_information(emp_cpd(:, :, t)));
    end    
end