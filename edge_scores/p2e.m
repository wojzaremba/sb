function [E, edge_opt, P, K] = p2e(nvars, maxS, p_all, set_size, edge_all)

% partition into different conditioning set sizes and compute sb scores
E = zeros(nvars);
P = NaN*ones(nvars);
K = NaN*ones(nvars);
edge_opt = {};
for k = 0:maxS
    % compute sb scores for conditioning sets of size k
    [sb, edge_opt{k + 1}] = learn_edge_classifier(p_all(set_size == k), k, true);
    p = p_all(set_size == k);
    % get max sb score for each edge
    edge = edge_all(set_size == k, :);
    for t = 1 : length(p)
        i = edge(t, 1);
        j = edge(t, 2);
        if (sb(t) > E(i,j))
            E(i,j) = sb(t);
            P(i,j) = p(t);
            K(i,j) = k;
        end
        E(i, j) = max(E(i, j), sb(t));
    end
end