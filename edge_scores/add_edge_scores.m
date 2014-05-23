function S = add_edge_scores(S, E, psi)


for i = 1:length(S)
  for k = 1:length(S{i})
    for p = S{i}{k}.parents
      edge = sort([i p]);
      fprintf('rho score = %f\n', S{i}{k}.score);
      fprintf('edge score = %f\n', E(edge(1), edge(2)));
      S{i}{k}.score = S{i}{k}.score - psi*E(edge(1), edge(2));     
    end
  end
end
