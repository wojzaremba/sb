function rho = kci_classifier(emp, options)
% returns a binary vector the same length as options.range, with 1
% signifying independence, and 0 dependence
%
% options.range is a set of threshold values

    if (size(emp, 1) < 3)       
        rho = kci(emp(1, :)', emp(2, :)', [], options);        
    else
        rho = kci(emp(1, :)', emp(2, :)', emp(3:end, :)', options);                
    end
    
    if rho < 0
        fprintf('WARNING: rho is negative in kci_classifier: %d\n',rho);
    end
%     printf(2, 'rho=%d\n',rho);
%     classes = threshold(options.range,rho);
    
end