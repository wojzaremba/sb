function [z, ind, p] = test_empirical_null(boot_flag, nboot)

global debug;
debug = 2;

% set defaults
if ~exist('boot_flag', 'var')
    boot_flag = false;
end
if ~exist('nboot', 'var')
    nboot = 100;
end

N = 400;
v = 0.05;
maxS = 2;

bnet = make_bnet(struct('network', 'child', 'moralize', false, 'arity', 1, 'type', 'quadratic_ggm', 'variance', v););
kci_opt = struct( 'pval', false, 'kernel', GaussKernel());
triples = gen_triples(size(bnet.dag, 1), 0:maxS);
p = [];
ind = [];

data = normalize_data(samples(bnet, N));
[D, pre] = preallocate(data, kci_opt, boot_flag, nboot);

for t = 1 : length(triples)
    i = triples{t}.i;
    j = triples{t}.j;
    for c = 1 : length(triples{t}.cond_set)
        p = [p compute_p(D, [i j triples{t}.cond_set{c}], kci_opt, pre)];
        ind = [ind dsep(i, j, triples{t}.cond_set{c}, bnet.dag)];
        fprintf('  %d %d cond set %d \n', i, j, c);
    end
    fprintf('DONE WITH %d %d\n', i, j);
end

% note that the p-values returned by kci are really 1 - p, but this will
% also be uniformly distributed under the null, hence z should still be
% N(0,1)
z = norminv(p); 
ind = logical(ind);

clear pre
save child_null_400_rho

end

function [D, pre] = preallocate(data, kci_opt, boot_flag, nboot)

if boot_flag
    fprintf('boot_flag\n');
    D = cell(nboot, 1);
    pre = cell(nboot, 1);
    N = size(data, 2);    
    for b = 1 : nboot
        y = randsample(N, N, true); 
        D{b} = data(:, y);
        pre{b} = kci_prealloc(D{b}, kci_opt);
    end
else
    fprintf('no boot_flag\n');
    D{1} = data;
    pre{1} = kci_prealloc(D{1}, kci_opt);
end

end

function p = compute_p(D, trip, opt, pre)

for b = 1 : length(D)
   p = kci_classifier(D{b}, trip, opt, pre{b}); 
end
if length(p) > 1
    z = norminv(p);
    [~, p] = kstest(z);
end

end


