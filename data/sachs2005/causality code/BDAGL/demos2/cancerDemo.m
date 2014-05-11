load 'cancerDataObs.mat' % from cancerMakeData 
% data is size d*N (nodes * cases), values are {1,2}
nNodes = 5;
maxFanIn = nNodes - 1; 

% all families log prior (size d * 2^d)
% impossible configurations are -inf
aflp = mkAllFamilyLogPrior( nNodes, 'maxFanIn', maxFanIn ); 

% all families log  marginal likelihood (size d * 2^d)
aflml = mkAllFamilyLogMargLik( data, 'nodeArity', repmat(2,1,nNodes), ...
			       'impossibleFamilyMask', aflp~=-Inf, ...
			       'priorESS', 1);
%aflml = mkAllFamilyLogMargLik(data, 'cpdType', 'gaussian').

% Use DP to compute edge marginals using modular prior
epDP = computeAllEdgeProb( aflp, aflml ); 
%logZ = computeLogZ(aflp, aflml);

figure(1); clf
subplot(2,2,1)
imagesc(epDP, [0 1 ]);
title('edge marginals (DP)')
colorbar;

% Now use MCMC with hybrid proposal, with uniform graph prior
[samples, diagnostics, runningSum] = sampleDags(@uniformGraphLogPrior, aflml, ...
				    'burnin', 100, 'verbose', true, ...
				    'edgeMarginals', epDP, 'globalFrac', 0.1, ...
				    'thinning', 2, 'nSamples', 5000);


epMCMC = samplesToEdgeMarginals(samples);

figure(1);
subplot(2,2,2)
imagesc(epMCMC, [0 1 ]);
title('edge marginals (MCMC)')
colorbar;
		
% Now use exhaustive enumeration with uniform prior
epEnumer = computeAllEdgeProb_Exact(0, aflml); % 0 denotes uniform prior

figure(1);
subplot(2,2,4);
imagesc(epEnumer, [0 1 ]);
title('edge marginals (enumer)')
colorbar

% Use DP to find exact MAP structure
optimalDAG = computeOptimalDag(aflml); 
%optimalDAG = computeOptimalDag(aflml+aflp);,


% Get ground truth
cancerMakeBN;

figure(1);
subplot(2,2,3)
imagesc(dag, [0 1]);
title('ground truth')
colorbar

% Visualize graph structures
labels = {'A', 'B', 'C', 'D', 'E'};

% Use pajek to automatically layout graph (external to matlab)
%adj2pajek2(dag, 'cancerDAG', 'nodeNames', labels)

% manual layout, in normalized [0..1]x[0..1] Matlab plotting coordinates
graphicalLayout = [0.4000 0.2000 0.6000 0.4000 0.8000 ; ...
		   0.7500 0.5000 0.5000 0.2500 0.2500 ];

figure(2); clf
subplot(2,2,1);
myDrawGraph(dag, 'labels', labels, 'layout', graphicalLayout)
title('ground truth')

subplot(2,2,2);
thresh = 0;
myDrawGraph(epDP, 'labels', labels, 'layout', graphicalLayout, 'thresh', thresh);
title(sprintf('DP thresh = %0.2f', thresh));

subplot(2,2,3);
thresh = 0.1;
myDrawGraph(epDP, 'labels', labels, 'layout', graphicalLayout, 'thresh', thresh);
title(sprintf('DP thresh = %0.2f', thresh));

subplot(2,2,4);
myDrawGraph(optimalDAG, 'labels', labels, 'layout', graphicalLayout)
title(sprintf('exact MAP'))

figure(3);clf
myDrawGraph(dag, 'labels', labels, 'layout', graphicalLayout)
title('cancer network')
