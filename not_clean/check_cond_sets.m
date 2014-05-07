function check_cond_sets(dag, maxS)

n = size(dag, 1);

triples = gen_triples(n, maxS);

for t = 1:length(triples)
   i = triples{t}.i;
   j = triples{t}.j;
   fprintf('%d, %d.. ', i, j);
   if (dag(i, j) || dag(j, i))
       fprintf('okay');
   else
       for c = 1:length(triples{t}.cond_set)
           cond = triples{t}.cond_set{c};
           if dsep(i, j, cond, dag)
               fprintf('okay');
               break;
           end
       end
   end
   fprintf('\n');
end
