disp('test_compute_rho_scores...');

randn('seed', 1);
rand('seed', 1);

N = 100;
maxK = 10;
n = 5;

bn_opt = struct('variance', 0.01, 'network', 'vstruct', 'arity', 1,... 
'type', 'quadratic_ggm', 'moralize', false, 'n', n);
bnet = make_bnet(bn_opt);

opt = struct( 'pval', false, 'kernel', GaussKernel(), 'classifier', ...
    @kci_classifier, 'prealloc', @kci_prealloc);

emp = normalize_data(samples(bnet,N));
pre = opt.prealloc(emp, opt);
[S, D] = compute_rho_scores(pre, maxK);

% check that D reflects that conditioning on more variables will make the
% score more favorable
assert( D(n, n, n) > D(n, 1, 2));

% check that the scores are in order of decreasing parent size
for i = 1 : length(S)
    for j = 1 : length(S{i})
        assert(~isnan(S{i}{j}.score && ~isinf(S{i}{j}.score)));
        if j > 1
            assert(length(S{i}{j}.parents) <= length(S{i}{j - 1}.parents));
        end
    end
end
