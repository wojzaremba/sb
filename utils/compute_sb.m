function rho = compute_sb(counts,eta,alpha) 

check_counts = true;

if (check_counts)
    total = sum(counts(:));
    if (total > 50)
        E = sb_expectation(counts,alpha);
        S = sqrt(sb_variance(counts,alpha));
        phi = gamcdf(eta,(E/S)^2,(S^2)/E);
        rho = 1 - phi;
    else % force classification to be dependent
        rho = 1;
    end
else
    E = sb_expectation(counts,alpha);
    S = sqrt(sb_variance(counts,alpha));
    phi = gamcdf(eta,(E/S)^2,(S^2)/E);
    rho = 1 - phi;
end
