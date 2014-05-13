function [total, num_ind, num_dep] = count_ind_cond_sets(dag, maxS)

global debug;
debug = 2;

n = size(dag, 1);
total = 0;
num_dep = 0;
num_ind = 0;

triples = gen_triples(n, [0 : maxS]);
for t = 1:length(triples)
    i = triples{t}.i;
    j = triples{t}.j;
    printf(2, '%d, %d.. ', i, j);
    if (dag(i, j) || dag(j, i))
        num_dep = num_dep + length(triples{t}.cond_set);
        total = total + length(triples{t}.cond_set);
        printf(2, '  edge.\n');
    else
        ind = 0;
        dep = 0;
        for c = 1:length(triples{t}.cond_set)
            cond = triples{t}.cond_set{c};
            if dsep(i, j, cond, dag)
                num_ind = num_ind + 1;
                ind = ind + 1;
            else
                num_dep = num_dep + 1;
                dep = dep + 1;
            end
            total = total + 1;
        end
        printf(2, '  ind = %d, dep = %d.\n', ind, dep);
    end
    printf(2, '\n');
end

assert(num_dep + num_ind == total);
