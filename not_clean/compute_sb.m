function rho = compute_sb(counts,eta) %,check_counts)

%if (check_counts)
    total = sum(counts(:));
    if (total > 50)
        alpha = 1;
        E = sb_expectation(counts,alpha);
        S = sqrt(sb_variance(counts,alpha));
        phi = gamcdf(eta,(E/S)^2,(S^2)/E);
        rho = 1 - phi;
    else % force classification to be dependent
        rho = 1;
    end
% else
%     alpha = 1;
%     E = sb_expectation(counts,alpha);
%     S = sqrt(sb_variance(counts,alpha));
%     phi = gamcdf(eta,(E/S)^2,(S^2)/E);
%     rho = 1 - phi;
% end
