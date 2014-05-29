function new_dag = moralize_dag(dag)

old_dag = dag;
new_dag = sweep_dag(dag);
printf(2, 'added %d new edges..\n', shd(old_dag, new_dag));
printf(2, 'max in-degree before: %d, after: %d\n', max(sum(old_dag, 1)), max(sum(new_dag, 1)));
printf(2, '  ..done.\n');

end

function new_dag = sweep_dag(dag)
% go through each variable once, check if it is the child of a v-structure,
% and induce clique over parents
n = size(dag,1);
for j = 1:n
    parents = [];
    for i = 1:n
        if dag(i,j) == 1
            parents = [parents i];
        end
    end
    if length(parents) > 1
        printf(2, 'inducing clique over ');
        printf(2, '%d ', parents);
        printf(2, '\n');
        dag = induce_clique(dag, parents);
    end
end

new_dag = dag;

end

