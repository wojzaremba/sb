function new_dag = induce_clique(dag, clique_set)

to_add = [];

for p = 1 : length(clique_set)
    for q = (p + 1) : length(clique_set)
        if (dag(clique_set(p), clique_set(q)) == 0 && ... 
                dag(clique_set(q), clique_set(p)) == 0)
            to_add = [to_add; clique_set(p) clique_set(q)];
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