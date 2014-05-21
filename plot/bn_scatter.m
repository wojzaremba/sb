function bn_scatter(data, dag)

K = size(dag, 1);
num_pairs = length(find(triu(dag, 1)));

for i = 1:K
    for j = i+1:K
        subplot(K-1, K-1, (K-1)*(i-1) + j-1)
        scatter(data(i, :), data(j, :));
        title(sprintf('%d and %d', i, j));
    end
end