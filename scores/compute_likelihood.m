function S = compute_likelihood(data, maxpa)
fprintf('computing likelihood...\n');
nvars = size(data, 1);
S = cell(nvars, 1);

for i = 1:nvars
    %S{i} = {};
    LL = compute_kernel_ridge_likelihood(i, [], data);
    S{i}{end + 1} = struct('score', LL, 'parents', []); 
    set = [1:i-1 i+1:nvars];
    for k = 1:maxpa
        cond_sets = combinations(set, k);
        for c = 1:size(cond_sets, 1)
            cond_set = cond_sets(c, :);
            LL = compute_kernel_ridge_likelihood(i, cond_set, data);
            S{i}{end + 1} = struct('score', LL, 'parents', cond_set);
        end
    end
end

% check for inf scores
for i = 1:length(S)
    for j = 1:length(S{i})
        assert(~isinf(S{i}{j}.score));
    end
end
fprintf('  finished. %f seconds\n', toc);


end