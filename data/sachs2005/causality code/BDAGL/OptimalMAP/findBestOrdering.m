function order = findBestOrdering(sinks)

nNodes = log2(length(sinks));

order = zeros(1,nNodes);
left = (2^nNodes);

for i=nNodes:-1:1
   order(i) = sinks(left);
   left = bitset(left-1, order(i), 0)+1;
end