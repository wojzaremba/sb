function new_dag = moralize_dag(dag)

old_dag = dag;
new_dag = sweep_dag(dag);
printf(2, 'added %d new edges..\n', shd(old_dag, new_dag));
printf(2, 'max in-degree before: %d, after: %d\n', max(sum(old_dag, 1)), max(sum(new_dag, 1)));

fprintf('WARNING- only sweeping through dag once.\n');
% % we may have induced new v-structures
% while ~isequal(dag, new_dag)
%     dag = new_dag; 
%     new_dag = sweep_dag(dag);
%     printf(2, 'added %d new edges..\n', shd(dag, new_dag));
% end
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

function new_dag = induce_clique(dag, parents)
to_add = [];

for p = 1 : length(parents)
    for q = (p + 1) : length(parents)
        if (dag(parents(p), parents(q)) == 0 && ... 
                dag(parents(q), parents(p)) == 0)
            to_add = [to_add; parents(p) parents(q)];
        end
    end
end

A = enumerate_assignments(size(to_add, 1), 2); 
for i = 1:size(A, 1)
    new_dag = dag;
    
    for j = 1:size(A, 2)
        if A(i,j) == 1
            new_dag(to_add(j, 1), to_add(j, 2)) = 1;
        else
            new_dag(to_add(j, 2), to_add(j, 1)) = 1;
        end
    end
    if isdag(new_dag)
        break
    end
end

assert(isdag(new_dag));

end