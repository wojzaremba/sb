function sorted = is_topol_sorted(dag)

n = size(dag, 1);

sorted = true;

for i = 1 : n
    for j = 1 : i
        if(dag(i,j) ~= 0)
            sorted = false;
            break;
        end
    end
end
