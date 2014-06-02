function parents = findBestNetwork(order, bps)

nNodes = length(order);
parents = zeros(1, nNodes);
predecs = 1;

for i=1:nNodes
    parents(order(i)) = bps(order(i), predecs);
    predecs = bitset(predecs-1, order(i), 1)+1;
end

