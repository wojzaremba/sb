function LL = compute_kernel_ridge_likelihood(X, Z, train, test)

if ~exist('test', 'var')
    test = train;
end

lambda = kci_constants();
G = GaussKernel();
T = size(train, 2);

x = train(X, :)';
xt = test(X, :)';
if ~isempty(Z)
    z = 0.5 * train(Z, :)'; % dividing by 2 just effectively makes 
    zt = 0.5 * test(Z, :)'; % the bandwidth wider for Z relative to X
    Kz = G.k(z, z);
    wz = x' * pdinv(Kz + lambda * eye(T)) * G.k(z, zt);
    LL = -norm(xt' - wz)^2;
else
    % XXX not sure about this one
    LL = -norm(xt)^2;
end

end