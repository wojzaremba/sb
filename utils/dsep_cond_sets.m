function T = dsep_cond_sets(dag, triples)

T = -Inf*ones(size(dag));
for t = 1:length(triples)
    trip = triples{t};
    for c = 1:length(trip.cond_set)
        T(trip.i, trip.j) = max(T(trip.i, trip.j), dsep(trip.i, trip.j, trip.cond_set{c}, dag));
    end
end