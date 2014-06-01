function [f_triples] = flatten_triples(triples)

f_triples = {};

for t = 1:length(triples)
    for c = 1:length(triples{t}.cond_set)
        next.i = triples{t}.i;
        next.j = triples{t}.j;
        next.cond_set = triples{t}.cond_set{c};
        f_triples{end+1} = next;
    end
end

end