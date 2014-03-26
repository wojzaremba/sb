function classes = kci_classifier(emp, options)
% returns a binary vector the same length as options.range, with 1
% signifying independence, and 0 dependence
%
% options.range is a set of threshold values
 
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
    
    printf(2, 'rho=%d\n',rho);
    classes = threshold(options.range,rho);
    
end