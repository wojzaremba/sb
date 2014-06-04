function LL = compute_kernel_ridge_likelihood(X, Z, train, test)

if ~exist('test', 'var')
    test = train;
end

lambda = kci_constants();
G = GaussKernel();
T = size(train, 2);
H =  eye(T) - ones(T, T) / T;

x = train(X, :)';
xt = test(X, :)';
if ~isempty(Z)
    z = 0.5*train(Z, :)'; % dividing by 2 just effectively makes 
    zt = 0.5*test(Z, :)'; % the bandwidth wider for Z relative to X
    Kz = G.k(z, z);
    Kzt = G.k(z, zt);
    wz = Kzt' * pdinv(Kz + lambda * eye(T)) * x;
    LL = -norm(xt - wz)^2;
else
    LL = -norm(xt)^2;
end

end