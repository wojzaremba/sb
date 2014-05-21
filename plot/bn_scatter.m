function bn_scatter(data, dag)

K = size(dag, 1);
for i = 1:K
    for j = i+1:K
        subplot(K-1, K-1, (K-1)*(i-1) + j-1)
        scatter(data(i, :), data(j, :));
        s = repmat(' (edge)',dag(i,j));
        title(sprintf('%d and %d %s', i, j, s));
    end
end