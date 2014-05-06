function [npval, Sta] = kci_classifier(emp, trip, options, prealloc)

T = size(emp, 2);

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

Sta_notnormal = abs(sum(Kx(:) .* Ky(:)));

if (isfield(options, 'pval') && options.pval)
    Num_eig = floor(T/4); % or T
    Thresh = 1E-5;
    
    % calculate the eigenvalues
    % Due to numerical issues, Kxz and Kyz may not be symmetric:
    [eig_Kx, eivx] = eigdec((Kx + Kx') / 2, Num_eig);
    [eig_Ky, eivy] = eigdec((Ky + Ky') / 2, Num_eig);
    
    % calculate the product of the square root of the eigvector and the eigen
    % vector
    IIx = find(eig_Kx > max(eig_Kx) * Thresh);
    IIy = find(eig_Ky > max(eig_Ky) * Thresh);
    eig_Kx = eig_Kx(IIx);
    eivx = eivx(:,IIx);
    eig_Ky = eig_Ky(IIy);
    eivy = eivy(:,IIy);
    
    eiv_prodx = eivx * diag(sqrt(eig_Kx));
    eiv_prody = eivy * diag(sqrt(eig_Ky));
    clear eivx eig_Kx eivy eig_Ky
    
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
    npval = gamcdf(Sta_notnormal, k_appr, theta_appr);
else
    assert(0); % spits out npval first, so just catch this for now
end

Sta = sqrt(Sta_notnormal / (sum(diag(Kx)) * sum(diag(Ky))));
