function [SHD] = shd(learned_PDAG, true_PDAG)

  if (length(find(diag(learned_PDAG)))>0 || length(find(diag(true_PDAG))) )
    error('SHD: input graphs should not have self-loops');
  end 
 
  % Get rid of all edges that are the same in both graphs
  same = find(learned_PDAG==true_PDAG);
  learned_PDAG(same) = 0;
  true_PDAG(same) = 0;

  % Count the cases where there is a reversal
  reversal = intersect(find(learned_PDAG), find(true_PDAG'));

  % Count the remaining undirected edges (the only possibility after the first step is that for every undirected edge in one graph, the other graph will not have the corresponding edge)
  undirected_learned = intersect(find(learned_PDAG),find(learned_PDAG'));
  undirected_true = intersect(find(true_PDAG),find(true_PDAG'));
  num_undirected = (length(undirected_learned) + length(undirected_true)) / 2; % divide by 2 because each edge is counted twice

  % Count total differences
  SHD = sum(sum(learned_PDAG ~= true_PDAG));

  % Subtract off the number of reversals, as we overcounted these.
  SHD = SHD - length(reversal) - num_undirected;
