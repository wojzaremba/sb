function mdag = moralize_dag(dag)

n = size(dag,1);

for j = 1:n
    parents = [];
    for i = 1:n
        if dag(i,j) == 1
            parents = [parents i];
        end
    end
    
end