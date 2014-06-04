% learn 5 node cancer network from interventional data
% If we ignore the fact that node A is set by intervention,
% we do not correctly recover the unique DAG.
% If we add an intervention node, we can learn its target.

clear all
cancerMakeBN;

load 'cancerDataInterA.mat' % from cancerMakeData 
% data is size d*N (nodes * cases), values are {1,2}
nNodes = 5;
maxFanIn = nNodes - 1; 

% all families log prior (size d * 2^d)
% impossible configurations are -inf
aflp = mkAllFamilyLogPrior( nNodes, 'maxFanIn', maxFanIn ); 

% Use known targets
aflml_perfect = mkAllFamilyLogMargLik( data, 'nodeArity', repmat(2,1,nNodes), ...
			       'impossibleFamilyMask', aflp~=-Inf, ...
			       'priorESS', 1, ...
			       'clampedMask', clamped);
epDP_perfect = computeAllEdgeProb( aflp, aflml_perfect ); 

% Ignore fact that data is interventional by omitting clamped mask
aflml = mkAllFamilyLogMargLik( data, 'nodeArity', repmat(2,1,nNodes), ...
			       'impossibleFamilyMask', aflp~=-Inf, ...
			       'priorESS', 1);
epDP = computeAllEdgeProb( aflp, aflml ); 

% Add intervention node as 6th node, and learn its target
N = size(data,2);
nObservationCases = N/2; % # observational data cases
nInterventionCases = N/2; % no interventions
assert(N==nObservationCases+nInterventionCases);
% intervention node is 1/2 time in state 1, 1/2 time in state 2
data_uncertain = [data; [ones(1,nObservationCases) 2*ones(1,nInterventionCases)]];
% intervention node is always clamped
clamped_uncertain = [zeros(size(clamped)); ones(1,N)];

% ground truth
dag_uncertain = zeros(6,6);
dag_uncertain(1:5,1:5) = dag;
dag_uncertain(6, 1) = 1; % true intervention target is A (1)


% fan-in
%     L1  L2
% L1   0   1    % only 1 intervention parent allowed for L2 nodes
% L2   0   max  % only max # paretns allowed in total for L2 nodes

maxFanIn_uncertain = [ 0 1 ; 0 maxFanIn ]; 
layering = [2*ones(1,nNodes) 1];
nodeArity = 2*ones(1,nNodes);
nodeArity_uncertain = [nodeArity 2];

aflp_uncertain = mkAllFamilyLogPrior( nNodes+1, 'maxFanIn', maxFanIn_uncertain, ...
				      'nodeLayering', layering );

aflml_uncertain = mkAllFamilyLogMargLik(data_uncertain, ...
		'nodeArity', nodeArity_uncertain, 'clampedMask', clamped_uncertain, ...
		'impossibleFamilyMask', aflp_uncertain~=-Inf, 'verbose', 0 );

epDP_uncertain = computeAllEdgeProb( aflp_uncertain, aflml_uncertain ); 



figure(1); clf
subplot(2,2,1)
imagesc(dag, [0 1]);
title('ground truth')
colorbar

subplot(2,2,2)
imagesc(epDP, [0 1 ]);
title('edge marginals (DP) - obs')
colorbar;

subplot(2,2,3)
imagesc(epDP_perfect, [0 1 ]);
title('edge marginals (DP) - perfect')
colorbar;

subplot(2,2,4)
imagesc(epDP_uncertain, [0 1 ]);
title('edge marginals (DP) - uncertain')
colorbar;

