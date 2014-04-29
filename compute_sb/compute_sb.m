function rho = compute_sb(counts,eta,alpha) 

    check_counts = true;
    total = sum(counts(:));

    if ((check_counts) && (total <= 50))
        % force classification to be dependent
        rho = ones(length(eta),length(alpha));
    else
        rho = compute_rho(counts,eta,alpha);
    end

end

function rho = compute_rho(counts,eta,alpha)
    rho = NaN*ones(length(eta),length(alpha));
    for i = 1:length(alpha);
        E = sb_expectation(counts,alpha(i));
        S = sqrt(sb_variance(counts,alpha(i)));
        if S ~= 0
            rho(:,i) = 1 - gamcdf(eta,(E/S)^2,(S^2)/E);
        else
            %XXX not sure if this is the right thing to do.  I added this
            %in order to match with the c++ code for a particular case when
            %S = 0, leading to gamcdf = -NaN, which in turn means that the
            %initialized value of min_edge_scores, 0, is kept. 0 = log(1).
            rho(:,i) = 1;

           
%             if E < eta
%                 rho(:,i) = 0;
%             else
%                 rho(:,i) = 1;
%             end
        end
    end
end