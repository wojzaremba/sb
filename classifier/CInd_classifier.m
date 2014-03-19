function Sta = CInd_classifier(x, y, z)


T = length(y); % the sample size
Thresh = 1E-5;
% normalize the data
x = x - repmat(mean(x), T, 1);
x = x * diag(1./std(x));
y = y - repmat(mean(y), T, 1);
y = y * diag(1./std(y));
z = z - repmat(mean(z), T, 1);
z = z * diag(1./std(z));
D = size(z, 2);

if T <= 200  
    width = 1.2; 
elseif T < 1200
     width = 0.7; 
else
    width = 0.4;
end
theta = 1/(width^2 * D); % I use this parameter to construct kernel matices. Watch out!! width = sqrt(2) sigma  AND theta= 1/(2*sigma^2)

H =  eye(T) - ones(T,T)/T; % for centering of the data in feature space
Kx = kernel([x z/2], [x z/2], [theta,1]); Kx = H * Kx * H;
Ky = kernel([y], [y], [theta,1]); Ky = H * Ky * H;  %%%%Problem
% later with optimized hyperparameters

% learning the hyperparameters
[eig_Kx, eix] = eigdec((Kx+Kx')/2, min(400, floor(T/4))); % /2
[eig_Ky, eiy] = eigdec((Ky+Ky')/2, min(200, floor(T/5))); % /3
% disp('  covfunc = {''covSum'', {''covSEard'',''covNoise''}};')
covfunc = {'covSum', {'covSEard','covNoise'}};
logtheta0 = [log(width * sqrt(D))*ones(D,1) ; 0; log(sqrt(0.1))];
fprintf('Optimizing hyperparameters in GP regression...\n');
IIx = find(eig_Kx > max(eig_Kx) * Thresh); eig_Kx = eig_Kx(IIx); eix = eix(:,IIx);
IIy = find(eig_Ky > max(eig_Ky) * Thresh); eig_Ky = eig_Ky(IIy); eiy = eiy(:,IIy);
[logtheta_x, fvals_x, iter_x] = minimize(logtheta0, 'gpr_multi', -350, covfunc, z, 2*sqrt(T) *eix * diag(sqrt(eig_Kx))/sqrt(eig_Kx(1)));
[logtheta_y, fvals_y, iter_y] = minimize(logtheta0, 'gpr_multi', -350, covfunc, z, 2*sqrt(T) *eiy * diag(sqrt(eig_Ky))/sqrt(eig_Ky(1)));

covfunc_z = {'covSEard'};
Kz_x = feval(covfunc_z{:}, logtheta_x, z);
Kz_y = feval(covfunc_z{:}, logtheta_y, z);

% Note: in the conditional case, no need to do centering, as the regression
% will automatically enforce that.

% Kernel matrices of the errors
P1_x = (eye(T) - Kz_x*pdinv(Kz_x + exp(2*logtheta_x(end))*eye(T)));
Kxz = P1_x* Kx * P1_x';
P1_y = (eye(T) - Kz_y*pdinv(Kz_y + exp(2*logtheta_y(end))*eye(T)));
Kyz = P1_y* Ky * P1_y';
% calculate the statistic
Sta = trace(Kxz * Kyz);
