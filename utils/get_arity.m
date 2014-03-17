function arity = get_arity(bnet)

arity = unique(bnet.node_sizes);
%fprintf('arity = %d',arity);
if length(arity) > 1
    error('All variables should have the same number of states');
end
