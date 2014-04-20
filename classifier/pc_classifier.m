function rho = pc_classifier(emp, options)
% returns partial correlation, i.e. correlation of residuals after
% conditioning on all variables in conditioning set

    if (size(emp, 1) < 3)
        %rho = partialcorr(emp(1, :)', emp(2, :)'); 
        rho = abs(corr(emp(1,:)',emp(2,:)'));
    else
        rho = abs(partialcorr(emp(1, :)', emp(2, :)', emp(3:end, :)'));  
    end
end
