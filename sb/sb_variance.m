function [varI] = sb_variance(D,prior)
%Computes the approximate variance of the posterior
%distribution of mutual information assuming a uniform prior, as presented
%in Hutter 2001, equation 3.  Note that this uses natural log, as specified
%in the paper.

[k,l] = size(D);
%n = sum(D(:));

% incorporate prior information
%prior = 1;
D = D + prior*ones(k,l);
n = sum(D(:));
nn = n + 1; % either normalize by n or n+1, following either Hutter 2001 or 2004 paper, respectively

% compute first term
first = 0;
for i = 1:k
    nip = sum(D(i,:));
    for j = 1:l
        npj = sum(D(:,j));
        if (D(i,j) ~= 0) %unnecessary for uniform prior, but in case prior is changed, this is needed
            first = first + (D(i,j)/n) * ( log(D(i,j)*n/(nip*npj)) )^2;  
        end
    end
end
first = first / nn;  

% compute second term
second = 0;
for i = 1:k
    nip = sum(D(i,:));
    for j = 1:l
        npj = sum(D(:,j));
        if (D(i,j) ~= 0) %unnecessary for uniform prior, but in case prior is changed, this is needed
            second = second + (D(i,j)/n) * log(D(i,j)*n/(nip*npj));  
        end
    end
end
second = (second^2) / nn;

varI = first - second;


end

