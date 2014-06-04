function dag = computeOptimalDag(scores)

bps = findBestParents(scores);
sinks = findBestSinks(bps, scores);
order = findBestOrdering(sinks);
parents = findBestNetwork(order, bps);

dag = parentsToDag(parents); 