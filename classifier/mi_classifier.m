function rho = mi_classifier(emp, trip, options, prealloc)
% returns either maximum mutual information over all assignments to
% conditioning set, or a weighted mean
    emp = emp(trip,:);
    [emp_dist, counts] = emp_to_dist(emp, options.arity);
    emp_dist = emp_dist(:, :, :);
    counts = counts(:);
    
    assert(sum(counts) == size(emp, 2));

    if strcmpi(options.aggregation,'min')
        rho = -Inf;
        
        for t = 1:size(emp_dist, 3)
        
            % take weakest evidence for independence
            rho = max(rho,mutual_information(emp_dist(:, :, t)));
            if (abs(rho - options.rho_range(2)) < 1e-4)
                break
            end
        end

    elseif strcmpi(options.aggregation, 'mean')
        rho = NaN*ones(size(emp_dist, 3),1);
        for t = 1:size(emp_dist, 3)
            rho(t) = mutual_information(emp_dist(:, :, t));
        end
        rho = (rho'*counts) / sum(counts);
    else
        error('unexpected value in options.aggregation.');
    end

end

