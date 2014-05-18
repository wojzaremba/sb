% network params
network = 'child';
type = 'quadratic_ggm';
variance = 0.05;

% run params
N = 100;
maxS = 2;
pval = true;
save_flag = true;

bnet = make_bnet(struct('network', network, 'moralize', false, ...
    'arity', 1, 'type', type, 'variance', variance));
kci_opt = struct( 'pval', pval, 'kernel', GaussKernel());
triples = gen_triples(size(bnet.dag, 1), 0:maxS);
data = normalize_data(samples(bnet, N));
pre = kci_prealloc(data, kci_opt);

bnet.dag
Kyz = pre.Kyz;
D = zeros(20, 20, 20);
for i = 1:20
    for j = 1:20
        for k = 1:20
            D(i, j, k) = norm(Kyz(:, :, i, j, k));
%             fprintf('i = %d, j = %d, k = %d, val = %f\n', i, j, k, );
        end
    end
end


E = zeros(20, 20);
for i = 1:20
    for j = 1:20
        E(i, j) = D(i, j, j);
    end
end