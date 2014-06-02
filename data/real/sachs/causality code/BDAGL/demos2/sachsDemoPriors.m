% compare different priors

load 'sachsDiscretizedData.mat';
% data is size d*N (nodes * cases), values are {1,2,3}

% let us subsample the data (as in Werhli'07) so
% the effect of the prior is stronger
% We have 600 samples for each of 9 conditions.
% Let us take 10 samples for each of 9.

ndx = [];
for i=1:9
  ndx = [ndx (1:10)+600*(i-1)];
end
data  = data(:,ndx);
clamped = clamped(:,ndx);

nNodes = 11;
maxFanIn = 2; 

% Get ground truth
[dag, F, H] = sachsTrueDAG();

nr = 3; nc = 2;
figure(1);clf
subplot(nr,nc,1)
imagesc(dag, [0 1]);
title('ground truth')
colorbar

% all families log prior (size d * 2^d)
% impossible configurations are -inf
aflp = mkAllFamilyLogPrior( nNodes, 'maxFanIn', maxFanIn ); 

% all families log  marginal likelihood (size d * 2^d)
aflml = mkAllFamilyLogMargLik( data, 'nodeArity', repmat(3,1,nNodes), ...
			       'impossibleFamilyMask', aflp~=-Inf, ...
			       'priorESS', 1, ...
			       'clampedMask', clamped);

% Use DP to compute edge marginals using modular prior
epDP = computeAllEdgeProb( aflp, aflml ); 
%logZ = computeLogZ(aflp, aflml);

figure(1);
subplot(nr,nc,2)
imagesc(epDP, [0 1 ]);
title('edge marginals (DP)')
colorbar;


% Use DP to find exact MAP structure
optimalDAG = computeOptimalDag(aflml); 
%optimalDAG = computeOptimalDag(aflml+aflp);,

figure(1);
subplot(nr,nc,3)
imagesc(optimalDAG, [0 1]);
title('optimal MAP')
colorbar

% Now use MCMC with hybrid proposal, and various priors
N = 5000;
[samples, diagnostics, runningSum] = sampleDags(@sachsGraphLogPriorCheat, aflml, ...
				    'burnin',1000, 'verbose', true, ...
				    'edgeMarginals', epDP, 'globalFrac', 0.1, ...
				    'thinning', 2, 'nSamples', N);
epMCMCpriorCheat = samplesToEdgeMarginals(samples);


[samples, diagnostics, runningSum] = sampleDags(@sachsGraphLogPriorKEGG, aflml, ...
				    'burnin',1000, 'verbose', true, ...
				    'edgeMarginals', epDP, 'globalFrac', 0.1, ...
				    'thinning', 2, 'nSamples', N);
epMCMCpriorKEGG = samplesToEdgeMarginals(samples);


[samples, diagnostics, runningSum] = sampleDags(@uniformGraphLogPrior, aflml, ...
				    'burnin',1000, 'verbose', true, ...
				    'edgeMarginals', epDP, 'globalFrac', 0.1, ...
				    'thinning', 2, 'nSamples', N);
epMCMCpriorUnif = samplesToEdgeMarginals(samples);

figure(1);
subplot(nr,nc,4)
imagesc(epMCMCpriorUnif, [0 1 ]);
title('MCMC uniform prior')
colorbar;


subplot(nr,nc,5)
imagesc(epMCMCpriorKEGG, [0 1 ]);
title('MCMC KEGG prior')
colorbar;

subplot(nr,nc,5)
imagesc(epMCMCpriorCheat, [0 1 ]);
title('MCMC Cheat prior')
colorbar;



% ROC curves
load('sachsPriorKEGG.mat') % from A. Werhli and D. Husmeier, 2007
[AUC_dp, FPrate_dp, TPrate_dp, thresholds] = cROC(epDP(:), dag(:));
[AUC_unif, FPrate_unif, TPrate_unif, thresholds] = cROC(epMCMCpriorUnif(:), dag(:));
[AUC_kegg, FPrate_kegg, TPrate_kegg, thresholds] = cROC(epMCMCpriorKEGG(:), dag(:));
[AUC_cheat, FPrate_cheat, TPrate_cheat, thresholds] = cROC(epMCMCpriorCheat(:), dag(:));
[AUC_prior, FPrate_prior, TPrate_prior, thresholds] = cROC(Gprior(:), dag(:));

figure(4); clf
plot(FPrate_dp, TPrate_dp, 'r-');
hold on
plot(FPrate_unif, TPrate_unif, 'b-');
plot(FPrate_kegg, TPrate_kegg, 'k-');
plot(FPrate_cheat, TPrate_cheat, 'g-');
plot(FPrate_prior, TPrate_prior, 'c-');
legendstr{1} = sprintf('dp %3.2f', AUC_dp);
legendstr{2} = sprintf('mcmc unif %3.2f', AUC_unif);
legendstr{3} = sprintf('mcmc kegg %3.2f', AUC_kegg);
legendstr{4} = sprintf('mcmc cheat %3.2f', AUC_cheat);
legendstr{5} = sprintf('kegg prior %3.2f', AUC_prior);
legend(legendstr)
title('Sachs with 90 data samples')


figure(5); clf
plot(FPrate_dp, TPrate_dp, 'r-');
hold on
plot(FPrate_unif, TPrate_unif, 'b:');
plot(FPrate_cheat, TPrate_cheat, 'g--');
legendstr{1} = sprintf('dp %3.2f', AUC_dp);
legendstr{2} = sprintf('mcmc unif %3.2f', AUC_unif);
legendstr{3} = sprintf('mcmc cheat %3.2f', AUC_cheat);
legend(legendstr)


if 0
% Visualize graph structures
load('sachsScienceLayout')

figure(3); clf
myDrawGraph(dag, 'labels', labels, 'layout', graphicalLayout)
title('ground truth')

figure(4); clf
myDrawGraph(optimalDAG, 'labels', labels, 'layout', graphicalLayout)
title(sprintf('exact MAP'))
end
