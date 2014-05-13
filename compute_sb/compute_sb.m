function [rho, info] = compute_sb(counts,eta,alpha) 

    check_counts = true;
    total = sum(counts(:));
    info = struct('low_counts', false, 'check_counts', check_counts, 'total', total);


    if ((check_counts) && (total <= 50))
        % force classification to be dependent
        rho = ones(length(eta),length(alpha));
        info.low_counts = true;
    else
        [rho, info] = compute_rho(counts,eta,alpha);
    end

end

function [rho, info] = compute_rho(counts, eta, alpha)
    
    rho = NaN * ones(length(eta), length(alpha));
    for i = 1 : length(alpha);
        info.E = sb_expectation(counts, alpha(i));
        info.V = sb_variance(counts, alpha(i));
        if info.V ~= 0
            rho(:,i) = 1 - gamcdf(eta, (info.E^2) / info.V, info.V / info.E);
        else
            %XXX not sure if this is the right thing to do.  I added this
            %in order to match with the c++ code for a particular case when
            %S = 0, leading to gamcdf = -NaN, which in turn means that the
            %initialized value of min_edge_scores, 0, is kept. 0 = log(1).
            rho(:, i) = 1;
            info.V_eq_0 = true;
           
%             if E < eta
%                 rho(:,i) = 0;
%             else
%                 rho(:,i) = 1;
%             end
        end
    end
end