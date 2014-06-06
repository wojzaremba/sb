function [E, edge_opt] = p2e(nvars, maxS, p_all, set_size, edge_all)

% partition into different conditioning set sizes and compute sb scores
E = zeros(nvars);
for k = 0:maxS
    % compute sb scores for conditioning sets of size k
    [sb, edge_opt{k + 1}] = learn_edge_classifier(p_all(set_size == k), k, false);
    
    % get max sb score for each edge
    edge = edge_all(set_size == k, :);
    for t = 1 : length(sb)
        i = edge(t, 1);
        j = edge(t, 2);
        E(i, j) = max(E(i, j), sb(t));
    end
end