function classes = mi_classifier(emp, options)
% returns a binary vector the same length as options.range, with 1
% signifying independence, and 0 dependence
%
% options.range is a set of threshold values

    emp_cpd = emp_to_cpd(emp, options.arity);
    emp_cpd = emp_cpd(:, :, :);

    rho = -Inf;
    for t = 1:size(emp_cpd, 3)
        rho = max(rho, mutual_information(emp_cpd(:, :, t)));
    end
    
    printf(2, 'rho=%d\n',rho);
    classes = threshold(options.range,rho);
end