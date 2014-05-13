function [rho, info] = mi_classifier(emp, trip, options, prealloc)
% returns maximum mutual information over all assignments to
% conditioning set
    
emp = emp(trip,:);
emp_dist = emp_to_dist(emp, options.arity);
emp_dist = emp_dist(:, :, :);

maxval = log2(options.arity);

rho = 0;
info = struct();

for t = 1:size(emp_dist, 3)
    
    % take weakest evidence for independence
    rho_new = mutual_information(emp_dist(:, :, t));   
    if rho_new > rho
        rho = rho_new;
        info.t = t;
    end

    if (rho >= maxval - 1e-4)
        break
    end
end

assert((0 <= rho) && (rho <= maxval));

end

