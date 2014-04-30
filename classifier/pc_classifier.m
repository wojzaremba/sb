function rho = pc_classifier(emp, trip, options, prealloc)
% returns partial correlation, i.e. correlation of residuals after
% conditioning on all variables in conditioning set
    emp = emp(trip,:);
    if (size(emp, 1) < 3)
        rho = abs(my_corr(emp(1,:)',emp(2,:)'));
    else
        rho = abs(partialcorr(emp(1, :)', emp(2, :)', emp(3:end, :)'));  
    end
   
    assert((0 <= rho) && (rho <= 1));
end
