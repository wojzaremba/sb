function best_parents = find_best_parents(S)

for i = 1:length(S)
   for j = 1:length(S{i})
       scores(j) = S{i}{j}.score;
   end
   k = find(scores == max(scores));
   disp(sprintf('%s for node %d', num2str(S{i}{k}.parents), i));
   best_parents{i} = S{i}{k}.parents;
   scores = [];
end