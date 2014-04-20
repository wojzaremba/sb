function rho = kci_classifier(emp, options)
% returns kci statistic using kernel set in options

    if (size(emp, 1) < 3)       
        rho = kci(emp(1, :)', emp(2, :)', [], options);        
    else
        rho = kci(emp(1, :)', emp(2, :)', emp(3:end, :)', options);                
    end
    
    if rho < 0
        fprintf('WARNING: rho is negative in kci_classifier: %d\n',rho);
    end
   
end