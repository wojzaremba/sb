function A = enumerate_assignments(k,arity)
A = zeros(arity^k, k);
for t = 0:(arity^k-1)                   
    for v = 1:k
        A(t + 1, v) = mod(floor(t / arity^(v-1)), arity) + 1;
    end
end
