function Sta = kci(x, y, z, options)
lambda = 1E-3; 
%lambda = 1e-10;
T = length(y); % the sample size
% % normalize the data
% if (options.normalize)
%     x = x - repmat(mean(x), T, 1);
%     x = x * diag(1./std(x));
%     y = y - repmat(mean(y), T, 1);
%     y = y * diag(1./std(y));
% end
H =  eye(T) - ones(T, T) / T; % for centering of the data in feature space
Ky = options.kernel.k(y, y);
Ky = H * Ky * H; 

if (exist('z', 'var') && (~isempty(z)))
%     if (options.normalize)
%         z = z - repmat(mean(z), T, 1);
%         z = z * diag(1./std(z));
%     end

    Kx = options.kernel.k([x z/2], [x z/2]); 
    Kx = H * Kx * H;

    Kz = options.kernel.k(z, z);
    Kz = H * Kz * H; 
    % Kernel matrices of the errors
    P1 = (eye(T) - Kz*pdinv(Kz + lambda*eye(T)));
    Kxz = P1 * Kx * P1';
    Kyz = P1 * Ky * P1';
    % calculate the statistic
    Sta = sum(Kxz(:) .* Kyz(:)) / sqrt(sum(Kxz(:) .^ 2) * sum(Kyz(:) .^ 2));
else
    Kx = options.kernel.k(x, x);
    Kx = H * Kx * H; 
    Sta = sum(Kx(:) .* Ky(:)) / sqrt(sum(Kx(:) .^ 2) * sum(Ky(:) .^ 2));    
end

