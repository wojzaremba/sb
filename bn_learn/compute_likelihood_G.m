function LL = compute_likelihood_G(G, train, test)

LL = 0;
for X = 1:size(G, 2)
    Z = find(G(:,X))';
    LL = LL + compute_kernel_ridge_likelihood(X, Z, train, test);
end

end