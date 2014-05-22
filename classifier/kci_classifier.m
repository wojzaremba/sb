function [rho, info] = kci_classifier(emp, trip, options, prealloc)

T = size(emp, 2);

if ~exist('prealloc', 'var')
    prealloc = [];
end

if ~isfield(options, 'pval')
    options.pval = true;
end

if ~isempty(prealloc)
    if (length(trip) >= 3)
        
        if (size(trip, 2) == 3)
            Kx = prealloc.Kxz(:, :, trip(1), trip(3), trip(3));
            Ky = prealloc.Kyz(:, :, trip(2), trip(3), trip(3));
            if options.pval
                eig_Kx = prealloc.Kxz_eigval(:, trip(1), trip(3), trip(3));
                eivx = prealloc.Kxz_eigvec(:, :, trip(1), trip(3), trip(3));
                eig_Ky = prealloc.Kyz_eigval(:, trip(2), trip(3), trip(3));
                eivy = prealloc.Kyz_eigvec(:, :, trip(2), trip(3), trip(3));
            end
        elseif (size(trip, 2) == 4)
            assert(trip(4) > trip(3));
            Kx = prealloc.Kxz(:, :, trip(1), trip(3), trip(4));
            Ky = prealloc.Kyz(:, :, trip(2), trip(3), trip(4));
            if options.pval
                eig_Kx = prealloc.Kxz_eigval(:, trip(1), trip(3), trip(4));
                eivx = prealloc.Kxz_eigvec(:, :, trip(1), trip(3), trip(4));
                eig_Ky = prealloc.Kyz_eigval(:, trip(2), trip(3), trip(4));
                eivy = prealloc.Kyz_eigvec(:, :, trip(2), trip(3), trip(4));
            end
        else
            assert(0);
        end
    else
        Kx = prealloc.K(:, :, trip(1));
        Ky = prealloc.K(:, :, trip(2));
        if options.pval
            eig_Kx = prealloc.K_eigval(:, trip(1));
            eivx = prealloc.K_eigvec(:, :, trip(1));
            eig_Ky = prealloc.K_eigval(:, trip(2));
            eivy = prealloc.K_eigvec(:, :, trip(2));
        end
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

Sta_unnormalized = abs(sum(Kx(:) .* Ky(:)));

if options.pval
    Num_eig = floor(T/4); % or T
    Thresh = 1E-5;
    
    % calculate the eigenvalues
    % Due to numerical issues, Kxz and Kyz may not be symmetric:
    if isempty(prealloc)
        [eig_Kx, eivx] = eigdec((Kx + Kx') / 2, Num_eig);
        [eig_Ky, eivy] = eigdec((Ky + Ky') / 2, Num_eig);
    end
    
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
    pval = gamcdf(Sta_unnormalized, k_appr, theta_appr);
else
    pval = NaN; 
end

Sta = sqrt(Sta_unnormalized / (sum(diag(Kx)) * sum(diag(Ky))));

if (isfield(options, 'pval') && options.pval)
    rho = pval;
else
    rho = Sta;
end

info.Sta = Sta;
info.Sta_unnorm = Sta_unnormalized;
info.pval = pval;
