function ret = kci_prealloc_save(emp, options)
printf(2, 'kci_prealloc...\n');
lambda = 1E-3;
T = size(emp, 2);
num_vars = size(emp, 1); 
H =  eye(T) - ones(T, T) / T;
K = zeros(T, T, num_vars);
Kxz = zeros(T, T, num_vars, num_vars, num_vars);
Kyz = zeros(T, T, num_vars, num_vars, num_vars);
for i = 1 : num_vars
    K(:, :, i) = Ky_comp(emp(i, :)');
end
for i = 1 : num_vars
    P1 = P_comp(emp(i, :)');
    for k = 1:num_vars
        Kx = Kxz_comp(emp(k, :)', emp(i, :)');
        Kxz(:, :, k, i, i) = P1 * Kx * P1';        
        Kyz(:, :, k, i, i) = P1 * K(:, :, k) * P1';
    end    
    for j = (i + 1):num_vars
        P1 = P_comp(emp([i, j], :)');
        for k = 1:num_vars
            Kx = Kxz_comp(emp(k, :)', emp([i, j], :)');
            Kxz(:, :, k, i, j) = P1 * Kx * P1';
            Kyz(:, :, k, i, j) = P1 * K(:, :, k) * P1';
        end
    end
    printf(2, 'finished i = %d\n', i);
end
ret = struct('K', K, 'Kxz', Kxz, 'Kyz', Kyz);

function ret = P_comp(z)
Kz = options.kernel.k(z, z);
Kz = H * Kz * H;
ret = (eye(T) - Kz*pdinv(Kz + lambda*eye(T)));
end

function ret = Kxz_comp(x, z)
ret = H * options.kernel.k([x z/2], [x z/2]) * H;
end

function ret = Ky_comp(y)
    ret = H * options.kernel.k(y, y) * H;    
end
end