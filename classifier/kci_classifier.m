function Sta = kci_classifier(emp, trip, prealloc, options)


if (length(trip) >= 3)
         
    if (size(trip, 2) == 3)
        Kxz = prealloc.Kxz(:, :, trip(1), trip(3), trip(3));
        Kyz = prealloc.Kyz(:, :, trip(2), trip(3), trip(3)); 
    elseif (size(trip, 2) == 4)
        assert(trip(4) > trip(3));
        Kxz = prealloc.Kxz(:, :, trip(1), trip(3), trip(4));
        Kyz = prealloc.Kyz(:, :, trip(2), trip(3), trip(4));
    else
        assert(0);
    end

    % calculate the statistic
    Sta = sqrt(abs(sum(Kxz(:) .* Kyz(:)) / (sum(diag(Kxz)) * sum(diag(Kyz)))));
else
    Kx = prealloc.K(:, :, trip(1));
    Ky = prealloc.K(:, :, trip(2));
    
    % calculate the statistic
    Sta = sqrt(abs(sum(Kx(:) .* Ky(:)) / (sum(diag(Kx)) * sum(diag(Ky)))));
end

