function indep = correlation_classifier(emp, options)
% indep = 1 means that variables described by emp are independent.
% indep = 0 means that variables are dependent.
    emp = (emp - (options.arity + 1) / 2) / options.arity;
    if (size(emp, 1) < 3)
        rho = partialcorr(emp(1, :)', emp(2, :)');        
%         rho = partialcorr([emp(1, :)' emp(1, :)' .^ 2], [emp(2, :)' .^ 2 emp(2, :)']);    
    else
        rho = partialcorr(emp(1, :)', emp(2, :)', emp(3:end, :)');                
%         rho = partialcorr([emp(1, :)' emp(1, :)' .^ 2], [emp(2, :)' emp(2, :)' .^ 2], [emp(3:end, :)' emp(3:end, :)' .^ 2]);
    end
    indep = abs(rho) < options.threshold;
end