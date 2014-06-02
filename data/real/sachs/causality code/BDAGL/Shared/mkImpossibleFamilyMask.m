function impossibleFamilyMask = mkImpossibleFamilyMask(nNodes, maxFanIn, nodeLayering)

if nargin<2 || isempty(maxFanIn)
	maxFanIn = nNodes - 1;
end
if nargin<3 || isempty(nodeLayering)
	nodeLayering = ones(nNodes,1);
end

nLayers = length(unique(nodeLayering));
if length(maxFanIn) ~= nLayers
	error('maxFanIn must be of equal length to # of layers');
elseif( size(maxFanIn,1)==1 || size(maxFanIn,2)==1 ) % if maxFanIn is vector

	maxFanIn = diag(maxFanIn) + triu( repmat(-1, nLayers, nLayers), 1); % "-1 == "don't care""
	
	% maxFanIn(i,i) is the maximum *total* fan-in from all layers <=i 
	% maxFanIn(i,j) for i<j means the maximum fan-in from a particular layer j<i
	% the lower triangular submatrix should never be used
end

% filter based on maxFanIn
baseMask = zeros(1, 2^nNodes);
baseMask( 2.^((1:nNodes)-1)+1 ) = 1;
baseMask = fumt(baseMask)>max(diag(maxFanIn));

impossibleFamilyMask = ~logical(repmat(baseMask, nNodes, 1));

% now set columns to zero if they contain the node of interest
for i=1:nNodes
	
	mask = zeros(1, 2^nNodes);
	mask( 2.^(i-1)+1 ) = 1;
	mask = fumt(mask)>0;
	
	impossibleFamilyMask( i, mask ) = 0;
end

if nLayers>1
	for i=1:nNodes
		% zero entries if they violate layering
		invalidParents = find(nodeLayering>nodeLayering(i));
		mask = zeros(1, 2^nNodes);
		mask( 2.^(invalidParents-1)+1 ) = 1;
		mask = fumt(mask)>0;
		impossibleFamilyMask(i, mask) = 0;

		% zero entries if they violate maxFanIn-layering
		% this refines the filter on maxFanIn above (which was not specific to a
		% particular child)
		for j=unique(nodeLayering(nodeLayering<=nodeLayering(i)))
			if maxFanIn(j,nodeLayering(i))==-1, continue; end % "no restriction"

			if j==nodeLayering(i)
				parents = (nodeLayering<=j);
			else
				parents = (nodeLayering==j);
			end
			
			parents(i) = 0; parents = find(parents);
			mask = zeros(1, 2^nNodes);
			mask( 2.^(parents-1)+1 ) = 1;
			mask = fumt(mask)>maxFanIn(j, nodeLayering(i));
			impossibleFamilyMask(i, mask) = 0;
		end
	end
end