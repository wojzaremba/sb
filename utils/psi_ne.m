function [psi] = psi_ne(n)
%PSI_NE  stands for psi-no-Euler, as it is the psi function without the
%Euler constant, since this will cancel out for our purposes.

psi = 0;

for k = 1:(n-1)
    psi = psi + 1/k;
end

end

