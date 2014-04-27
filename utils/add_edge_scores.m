function S = add_edge_scores(S, E)

K = size(E, 1);
nodes = 1:K;

for i = 1:length(S)
  for k = 1:length(S{i})
    non_edges = setdiff(nodes, [S{i}{k}.parents i]);
    for e = non_edges
      edge = sort([i e]);
      S{i}{k}.score = S{i}{k}.score + E(edge(1), edge(2));     
    end
  end
end
