function rho = kci_classifier(emp, options)
% indep = 1 / -1 means that variables described by emp are independent.
% indep = 0 means that variables are dependent.
    T = size(emp, 2);
    if T <= 200  
        width = 1.2; 
    elseif T < 1200
         width = 0.7; 
    else
        width = 0.4;
    end
    if (size(emp, 1) < 3)
        theta = 1/(width^2);
        kci_options = struct('kernel', @options.kernel, 'kernel_params', [theta, 1]);        
        rho = kci(emp(1, :)', emp(2, :)', [], kci_options);        
    else
        theta = 1/(width^2 * (size(emp, 1) - 2));
        kci_options = struct('kernel', @options.kernel, 'kernel_params', [theta, 1]);        
        rho = kci(emp(1, :)', emp(2, :)', emp(3:end, :)', kci_options);                
    end
end