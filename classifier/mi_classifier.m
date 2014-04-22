function rho = mi_classifier(emp, trip, options, prealloc)
% returns maximum mutual information over all assignments to conditioning set 
    emp = emp(trip,:);
    emp_dist = emp_to_dist(emp, options.arity);
    emp_dist = emp_dist(:, :, :);

    rho = -Inf;
    for t = 1:size(emp_dist, 3)
        rho = max(rho, mutual_information(emp_dist(:, :, t)));
        printf(2, 'rho=%d\n',rho);
        if (rho == options.rho_range(2))
            break
        end
        
%         if (abs(rho - options.rho_range(2)) < 1e-4)
%             break
%         end
    end

end
