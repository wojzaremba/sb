function ret = kci_prealloc(emp, options)
fprintf('calling kci_prealloc\n');
tic;
printf(2, 'kci_prealloc...\n');

if ~isfield(options, 'pval')
    options.pval = true;
end

[lambda, ~, eig_frac] = kci_constants();
T = size(emp, 2);
num_eig = floor(T * eig_frac);
num_vars = size(emp, 1); 
H =  eye(T) - ones(T, T) / T;
K = zeros(T, T, num_vars);
Kxz = zeros(T, T, num_vars, num_vars, num_vars);
Kyz = zeros(T, T, num_vars, num_vars, num_vars);

if options.pval
    printf(2, '  computing eig decompositions\n');
    K_eigval = zeros(num_eig, num_vars);
    K_eigvec = zeros(T, num_eig, num_vars);
    Kxz_eigval = zeros(num_eig, num_vars, num_vars, num_vars);
    Kxz_eigvec = zeros(T, num_eig, num_vars, num_vars, num_vars);
    Kyz_eigval = zeros(num_eig, num_vars, num_vars, num_vars);
    Kyz_eigvec = zeros(T, num_eig, num_vars, num_vars, num_vars);
end

parfor i = 1 : num_vars
    K(:, :, i) = H * options.kernel.k(emp(i,:)', emp(i,:)') * H;
    if options.pval
        Ky = K(:, :, i);
        [K_eigval(:, i), K_eigvec(:, :, i)] = eigdec((Ky + Ky') / 2, num_eig);
    end
end

% this one can't be parallelized (well maybe possible, but would have to
% rethink ordering)
for i = 1 : num_vars
    P1 = P_comp(emp(i, :)');
    for k = 1:num_vars
        Kx = H * options.kernel.k( [emp(k, :)' 0.5*emp(i, :)'], [emp(k, :)' 0.5*emp(i, :)'] ) * H;
        Kxz(:, :, k, i, i) = P1 * Kx * P1';        
        Kyz(:, :, k, i, i) = P1 * K(:, :, k) * P1';
        if options.pval
            Ky = Kxz(:, :, k, i, i);
            [Kxz_eigval(:, k, i, i), Kxz_eigvec(:, :, k, i, i)] = ...     
                eigdec((Ky + Ky') / 2, num_eig);
            
            Ky = Kyz(:, :, k, i, i);
            [Kyz_eigval(:, k, i, i), Kyz_eigvec(:, :, k, i, i)] = ...
                eigdec((Ky + Ky') / 2, num_eig);
        end
    end    
    for j = (i + 1):num_vars
        z = emp([i, j], :)';
        Kz = options.kernel.k(z, z);
        Kz = H * Kz * H;
        P1 = (eye(T) - Kz*pdinv(Kz + lambda*eye(T)));
        for k = 1:num_vars
            x = emp(k, :)';
            z = emp([i, j], :)';
            Kx = H * options.kernel.k([x z/2], [x z/2]) * H;
            Kxz(:, :, k, i, j) = P1 * Kx * P1';
            Kyz(:, :, k, i, j) = P1 * K(:, :, k) * P1';
            if options.pval
                Ky = Kxz(:, :, k, i, j);
                [Kxz_eigval(:, k, i, j), Kxz_eigvec(:, :, k, i, j)] = ...
                    eigdec((Ky + Ky') / 2, num_eig);
                
                Ky = Kyz(:, :, k, i, j);
                [Kyz_eigval(:, k, i, j), Kyz_eigvec(:, :, k, i, j)] = ...
                    eigdec((Ky + Ky') / 2, num_eig);      
            end
        end
    end
    printf(2, 'finished i = %d\n', i);
end

ret = struct('K', K, 'Kxz', Kxz, 'Kyz', Kyz);
if options.pval
    ret.K_eigval = K_eigval;
    ret.K_eigvec = K_eigvec; 
    ret.Kxz_eigval = Kxz_eigval;
    ret.Kxz_eigvec = Kxz_eigvec;
    ret.Kyz_eigval = Kyz_eigval;
    ret.Kyz_eigvec = Kyz_eigvec;
end

fprintf('   %f seconds\n', toc);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ret = P_comp(z)
Kz = options.kernel.k(z, z);
Kz = H * Kz * H;
ret = (eye(T) - Kz*pdinv(Kz + lambda*eye(T)));
end

% function ret = Kxz_comp(x, z)
% ret = H * options.kernel.k([x z/2], [x z/2]) * H;
% end

% function ret = Ky_comp(y)
%     ret = H * options.kernel.k(y, y) * H;    
% end

% function [eigvals, eigvecs] = Keig_comp(Ky)
%     [eigvals, eigvecs] = eigdec((Ky + Ky') / 2, num_eig);
% end

end
