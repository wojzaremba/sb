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
        rho(:,i) = 1 - gamcdf(eta,(E/S)^2,(S^2)/E);
    end
end