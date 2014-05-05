function [p_val, Sta] = kci_pval(x, y, z)
% To test if x and y are independent.
% INPUT:
%   The number of rows of x and y is the sample size.
% Output:
%   Cri: the critical point at the p-value equal to alpha obtained by bootstrapping.
%   Sta: the statistic Tr(K_{\ddot{X}|Z} * K_{Y|Z}).
%   p_val: the p value obtained by bootstrapping.
%   Cri_appr: the critical value obtained by Gamma approximation.
%   p_apppr: the p-value obtained by Gamma approximation.
% If Sta > Cri, the null hypothesis (x is independent from y) is rejected.
% Copyright (c) 2010-2011  ...
% All rights reserved.  See the file COPYING for license terms.


T = length(y); % the sample size
% Num_eig = floor(T/4); % how many eigenvalues are to be calculated?
Num_eig = T;
lambda = 1E-3; % the regularization paramter
Thresh = 1E-5;

H =  eye(T) - ones(T,T)/T; % for centering of the data in feature space
% Kx = kernel([x z], [x z], [theta,1]); Kx = H * Kx * H;
Kx = kernel([x z/2], [x z/2], [theta,1]); Kx = H * Kx * H;
% Ky = kernel([y z], [y z], [theta,1]); %Ky = Ky * H;
% Kx = kernel([x], [x], [theta,1]); %Kx = Kx * H; %%%%Problem
Ky = kernel([y], [y], [theta,1]); Ky = H * Ky * H;  %%%%Problem


Kz = kernel(z, z, [theta,1]); Kz = H * Kz * H; %*4 % as we will calculate Kz
% Kernel matrices of the errors
P1 = (eye(T) - Kz*pdinv(Kz + lambda*eye(T)));
Kxz = P1* Kx * P1';
Kyz = P1* Ky * P1';
% calculate the statistic
Sta = trace(Kxz * Kyz);

% degrees of freedom
df = trace(eye(T)-P1);

% calculate the eigenvalues
% Due to numerical issues, Kxz and Kyz may not be symmetric:
[eig_Kxz, eivx] = eigdec((Kxz+Kxz')/2,Num_eig);
[eig_Kyz, eivy] = eigdec((Kyz+Kyz')/2,Num_eig);

% calculate the product of the square root of the eigvector and the eigen
% vector
IIx = find(eig_Kxz > max(eig_Kxz) * Thresh);
IIy = find(eig_Kyz > max(eig_Kyz) * Thresh);
eig_Kxz = eig_Kxz(IIx);
eivx = eivx(:,IIx);
eig_Kyz = eig_Kyz(IIy);
eivy = eivy(:,IIy);

eiv_prodx = eivx * diag(sqrt(eig_Kxz));
eiv_prody = eivy * diag(sqrt(eig_Kyz));
clear eivx eig_Kxz eivy eig_Kyz
% calculate their product
Num_eigx = size(eiv_prodx, 2);
Num_eigy = size(eiv_prody, 2);
Size_u = Num_eigx * Num_eigy;
uu = zeros(T, Size_u);
for i=1:Num_eigx
    for j=1:Num_eigy
        uu(:,(i-1)*Num_eigy + j) = eiv_prodx(:,i) .* eiv_prody(:,j);
    end
end
if Size_u > T
    uu_prod = uu * uu';
else
    uu_prod = uu' * uu;
end

mean_appr = trace(uu_prod);
var_appr = 2*trace(uu_prod^2);
k_appr = mean_appr^2/var_appr;
theta_appr = var_appr/mean_appr;
%Cri_appr = gaminv(1-alpha, k_appr, theta_appr);
p_val = 1-gamcdf(Sta, k_appr, theta_appr);

