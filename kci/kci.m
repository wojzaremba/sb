function Sta = kci(x, y, z, options)

lambda = 1E-3; 
T = length(y); % the sample size
H =  eye(T) - ones(T, T) / T; % for centering of the data in feature space
Ky = options.kernel.k(y, y);
Ky = H * Ky * H;

if (exist('z', 'var') && (~isempty(z)))
    Kx = options.kernel.k([x z/2], [x z/2]); 
    Kx = H * Kx * H;

    Kz = options.kernel.k(z, z);
    Kz = H * Kz * H; 

    % Kernel matrices of the errors
    P1 = (eye(T) - Kz*pdinv(Kz + lambda*eye(T)));
    Kxz = P1 * Kx * P1';
    Kyz = P1 * Ky * P1';

    % calculate the statistic
    Sta = sqrt(abs(sum(Kxz(:) .* Kyz(:)) / (sum(diag(Kxz)) * sum(diag(Kyz)))));
else
    Kx = options.kernel.k(x, x);
    Kx = H * Kx * H; 
    
    % calculate the statistic
    Sta = sqrt(abs(sum(Kx(:) .* Ky(:)) / (sum(diag(Kx)) * sum(diag(Ky)))));
end

