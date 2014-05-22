function bn_scatter(data, dag, method)

if ~exist('method', 'var')
    method = 'scatter';
end

K = size(dag, 1);
for i = 1:K
    for j = i+1:K
        subplot(K-1, K-1, (K-1)*(i-1) + j-1)
        if strcmpi(method, 'scatter')
            scatter(data(i, :), data(j, :));
        elseif strcmpi(method, 'hist')
            hist3(data([i j], :)');
        end
        s = repmat(' (edge)',dag(i,j));
        title(sprintf('%d and %d %s', i, j, s));
    end
end