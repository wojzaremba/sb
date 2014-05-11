function [LM, parents] = logMargLikGaussFamilyAll(data, impossibleFamilyMask, intervention, verbose)
% Compute log p(x(i)|X(Gi))) for all nodes i and possible parents Gi
%
% data(cases m, nodes i)
% intervention.clampedMask(m, i) = 1 if node i is set by intervention in case m
% params = ...
%
% LM(i,u) = log p(x(i) | x(u)) for each possible parent set u
% LM(i,u) = 0 if u contains i
%
% parents{u} = [indices of nodes in column u]

global nNodes;

[mu0, T0, am, aw] = computeGaussHyperParams(nNodes);

LM = zeros(nNodes, 2^nNodes);
parents = cell(2^nNodes,1);

for k=0:2^nNodes-1
	pa = find(bitget(k,1:nNodes));
	parents{k+1} = pa;
	for i=1:nNodes
		if impossibleFamilyMask(i,k+1)==-Inf, % big speedup
			LM(i,k+1) = -Inf; 
			continue; 
		end
		LM(i,k+1) = logMargLikGaussFamily(data, pa, i, T0, mu0, am, aw, intervention);
	end
	
	if mod(k,1000) == 0 && verbose
		fprintf('%i/%i\n', k, 2^nNodes-1);
	end
	
end
