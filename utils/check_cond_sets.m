function all_okay = check_cond_sets(dag, maxS)

n = size(dag, 1);

triples = gen_triples(n, [0 : maxS]);
all_okay = true;

for t = 1:length(triples)
   okay = false;
   i = triples{t}.i;
   j = triples{t}.j;
   printf(2, '%d, %d.. ', i, j);
   if (dag(i, j) || dag(j, i))
       printf(2, 'okay');
       okay = true;
   else
       for c = 1:length(triples{t}.cond_set)
           cond = triples{t}.cond_set{c};
           if dsep(i, j, cond, dag)
               printf(2, 'okay');
               okay = true;
               break;
           end
       end
   end
   all_okay = all_okay && okay;
   printf(2, '\n');
end
