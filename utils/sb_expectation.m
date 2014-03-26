function [expI] = sb_expectation(D,prior)
%Computes the exact expectation of the posterior distribution of
%mutual information based on a uniform prior over the probability simplex.
%(See Hutter 2001 or Hutter & Zaffalon 2005)


[k,l] = size(D);

% incorporate prior information
prior = 1;
D = D + prior*ones(k,l);
n = sum(D(:));

expI = 0;
for i = 1:k
    nip = sum(D(i,:));
    for j = 1:l
        npj = sum(D(:,j));
        expI = expI + (D(i,j)*(psi_ne(D(i,j)+1)-psi_ne(nip+1)-psi_ne(npj+1)+psi_ne(n+1)));
    end
end

expI = expI / n;


end

