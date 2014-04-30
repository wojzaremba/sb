function rho = mi_classifier(emp, trip, options, prealloc)
% returns either maximum mutual information over all assignments to
% conditioning set, or a weighted mean
    emp = emp(trip,:);
    emp_dist = emp_to_dist(emp, options.arity);
    emp_dist = emp_dist(:, :, :);
    
    maxval = log2(options.arity);

        rho = 0;
        
        for t = 1:size(emp_dist, 3)
        
            % take weakest evidence for independence
            rho = max(rho,mutual_information(emp_dist(:, :, t)));
            if (rho >= maxval - 1e-4)
                break
            end
        end
        
        assert((0 <= rho) && (rho <= maxval));


end

