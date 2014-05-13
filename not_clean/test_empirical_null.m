function [z, ind] = test_empirical_null(plot_flag)

global debug;
debug = 2;

N = 100;
v = 0.05;
maxS = 2;

bn_opt = struct('network', 'child', 'moralize', false, 'arity', 1, 'type', 'quadratic_ggm', 'variance', v);
bnet = make_bnet(bn_opt);
data = normalize_data(samples(bnet, N));

K = size(bnet.dag, 1);

G = GaussKernel();
kci_opt = struct( 'pval', true, 'kernel', G);

triples = gen_triples(K, [0 : maxS]);
p = [];
ind = [];

pre = kci_prealloc(data, kci_opt);
for t = 1 : length(triples)
    i = triples{t}.i;
    j = triples{t}.j;
    for c = 1 : length(triples{t}.cond_set)
        trip = [i j triples{t}.cond_set{c}];
        p = [p kci_classifier(data, trip, kci_opt, pre)];
        ind = [ind dsep(i, j, triples{t}.cond_set{c}, bnet.dag)];
        fprintf('  %d %d cond set %d \n', i, j, c);
    end
    fprintf('DONE WITH %d %d\n', i, j);
end

z = norminv(1 - p);
ind = logical(ind);

% for now just throw out infinite values, but this will strongly affect
% results, so need to fix this.  Maybe more accurate p-value computations?
ind = ind(find(~isinf(z)));
z = z(find(~isinf(z)));


if plot_flag
    figure
    hold on
    scatter(z(ind), ones(size(z(ind))), 'r*');
    scatter(z(~ind), ones(size(z(~ind))), 'b*');
    legend('ind','dep');
    
    figure
    hist(z(ind),100);
    title('Independent distributions only');
    
    figure
    hist(z(~ind),100);
    title('Dependent distributions only');
    
    figure
    hist(z, 100);
    title('All distributions');
end
