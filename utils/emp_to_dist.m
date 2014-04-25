function D = emp_to_dist(emp, arity, normalize)

if ~exist('normalize','var')
   normalize = true; 
end

num_vars = size(emp,1);
N = size(emp,2);
D = allocate_tensor(arity, num_vars);

if num_vars == 1
    for n = 1:N
        D(emp(1,n)) = D(emp(1,n)) + 1;
    end
    if (normalize)
        D = D ./ sum(D(:));
    end
elseif num_vars == 2
    for n = 1:N
        D(emp(1,n), emp(2,n)) = D(emp(1,n), emp(2,n)) + 1;
    end
    if (normalize)
        D = D ./ sum(D(:));
    end
elseif num_vars == 3
    for n = 1:N
        D(emp(1,n), emp(2,n), emp(3,n)) = D(emp(1,n), emp(2,n), emp(3,n)) + 1;
    end
    if (normalize)
        for i = 1:arity
            D(:,:,i) = D(:,:,i) ./ sum(sum(D(:,:,i)));
        end
    end
elseif num_vars == 4
    for n = 1:N
        D(emp(1,n), emp(2,n), emp(3,n), emp(4,n)) = D(emp(1,n), emp(2,n), emp(3,n), emp(4,n)) + 1;
    end
    if (normalize)
        for i = 1:arity
            for j = 1:arity
                D(:,:,i,j) = D(:,:,i,j) ./ sum(sum(D(:,:,i,j)));
            end
        end
    end
else
    assert(0)
end


end

