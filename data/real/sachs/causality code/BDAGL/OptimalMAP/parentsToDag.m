function dag = parentsToDag(parents)
% convert array of parent sets to a full dag

nNodes = length(parents);
dag = zeros(nNodes);

for ni=1:nNodes
   
    bits = find(bitget( parents(ni)-1, 1:nNodes ));
    
    dag(bits, ni) = 1;
    
end