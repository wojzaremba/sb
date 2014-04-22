function Sta = kci_classifier(emp, trip, options, prealloc)

if (exist('prealloc','var') && ~isempty(prealloc))
    if (length(trip) >= 3)
        
        if (size(trip, 2) == 3)
            Kx = prealloc.Kxz(:, :, trip(1), trip(3), trip(3));
            Ky = prealloc.Kyz(:, :, trip(2), trip(3), trip(3));
        elseif (size(trip, 2) == 4)
            assert(trip(4) > trip(3));
            Kx = prealloc.Kxz(:, :, trip(1), trip(3), trip(4));
            Ky = prealloc.Kyz(:, :, trip(2), trip(3), trip(4));
        else
            assert(0);
        end
    else
        Kx = prealloc.K(:, :, trip(1));
        Ky = prealloc.K(:, :, trip(2));
    end
else
    x = emp(trip(1), :)';
    y = emp(trip(2), :)';
    lambda = 1E-3;
    T = size(emp, 2);
    H =  eye(T) - ones(T, T) / T;
    Ky = H * options.kernel.k(y, y) * H;
    
    if (length(trip) >= 3)
        z = emp(trip(3:end), :)';
        Kx = H * options.kernel.k([x z/2], [x z/2]) * H;
        Kz = H * options.kernel.k(z, z) * H;
        P = (eye(T) - Kz*pdinv(Kz + lambda*eye(T)));
        Kx = P * Kx * P';
	Ky = P * Ky * P'; 
    else
        Kx = H * options.kernel.k(x, x) * H;
    end
end

Sta = sqrt(abs(sum(Kx(:) .* Ky(:)) / (sum(diag(Kx)) * sum(diag(Ky)))));
