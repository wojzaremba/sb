disp('test_kernel_ridge_likelihood...');

seed_rand(3);
N = 300;

% create pair of vstructures and sample data
bn_opt = struct('network', 'vstruct', 'arity', 1, 'n', 3, 'data_gen', ...
    'quadratic_ggm', 'variance', 0.05, 'moralize', false, 'tile', 2);
bnet = make_bnet(bn_opt);
[train, mu, sigma] = normalize_data(samples(bnet, N));
test = normalize_data(samples(bnet, N), true, mu, sigma);

% first test that likelihood on training data increases as we increase the
% number of conditioning variables
LL = zeros(5, 1);
for i = 1:3
    set = [1:i-1 i+1:6];
    c4 = combinations(set, 4);
    for c = 1:size(c4, 1)
        for k = 0:size(c4, 2)
            LL(k+1) = compute_kernel_ridge_likelihood(i, c4(c, 1:k), train);
        end
        assert(issorted(LL));
    end
end

% second, test that the likelihood on test data is highest when we
% condition on the correct variables (i.e. the Markov blanket)
for i = 1:6
    set = [1:i-1 i+1:6];
    LL = compute_kernel_ridge_likelihood(i, [], train, test);
    C = {};
    C{1} = [];
    for k = 1:5
        cond_sets = combinations(set, k);
        for c = 1:size(cond_sets, 1)
            LL(end + 1) = compute_kernel_ridge_likelihood(i, ...
                cond_sets(c, :), train, test);
            C{end + 1} = cond_sets(c, :);
        end
    end
    [~, ind] = max(LL);
    if i <= 3
        assert(isequal(sort(C{ind}),setdiff(1:3, i)));
    else
        assert(isequal(sort(C{ind}),setdiff(4:6, i)));
    end
end



    
