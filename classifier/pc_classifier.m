function rho = pc_classifier(emp, options)
% returns a binary vector the same length as options.range, with 1
% signifying independence, and 0 dependence
%
% options.range is a set of threshold values

    if (size(emp, 1) < 3)
        %rho = partialcorr(emp(1, :)', emp(2, :)'); 
        rho = abs(corr(emp(1,:)',emp(2,:)'));
    else
        rho = abs(partialcorr(emp(1, :)', emp(2, :)', emp(3:end, :)'));                
    end
%     printf(2, 'rho=%d\n',rho);
%     classes = threshold(options.range,abs(rho));
end
