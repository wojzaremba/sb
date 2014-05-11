function [samples acceptanceRate edgeProb] = sampleJointMcmcDemo()

load('cancerLayout.mat');

%% make bnet
% bnet = mkCancer();
load('cancerDemoBnet.mat');

% dag = zeros(3);
% dag(1,[2 3]) = 1;
% 
% cpt1 = [.5 .5];
% cpt2 = [ .1 .9 ; .9 .1 ];
% cpt3 = [ .9 .1 ; .1 .9 ];
% 
% bnet = mk_bnet(dag, 2*ones(3,1));
% 
% bnet.CPD{1} = tabular_CPD(bnet, 1, 'CPT', cpt1);
% bnet.CPD{2} = tabular_CPD(bnet, 2, 'CPT', cpt2);
% bnet.CPD{3} = tabular_CPD(bnet, 3, 'CPT', cpt3);

nNodes = length(bnet.dag);

%% generate data
nMaxObservations = 2000;

observationData = zeros(nNodes, nMaxObservations);
observationClamped = zeros(size(observationData)); % always 0

for m = 1:nMaxObservations
	samp = sample_bnet(bnet);

	observationData(:,m) = cell2num(samp);
end

data = observationData;
clamped = observationClamped;

%% run koivisto
k = nNodes-1;
sz = bnet.node_sizes;
[edgeProb] = computeAllEdgeProb(data, sz, k, 'clamped', clamped);

%% sample from joint posterior by MCMC
nSamples = 30000;

isSuccess = false;
while ~isSuccess
	[dag logQ] = sampleDagFromEdgeMarginals( edgeProb );
	if acyclic(dag)
		isSuccess = true;
	end
end
logMargLik = logMargLikDag( dag, data', clamped', sz );
logPrior = uniformPrior( dag );
pr = logMargLik + logPrior;

samples = cell(1, nSamples);
samples{1} = dag;

acceptanceRate = zeros(1, nSamples);
numAccepts = 0;
numRejects = 0;

for si = 2:nSamples
	
	[dagp logQp] = sampleDagFromEdgeMarginals( edgeProb );

	logMargLikp = logMargLikDag( dagp, data', clamped', sz);
	logPriorp = uniformPrior( dagp );
	
	prp = logMargLikp + logPriorp;
	
	alpha = exp( prp - pr ) * exp( logQ - logQp );
	
	accept = rand<alpha;
	
% 	figure(1); clf; 
% 	subplot(1,2,1);
% 	myDrawGraph(dag, 'layout', cancerLayout); 
% 	title(sprintf('%f %f', pr, logQ));
% 	subplot(1,2,2);
% 	myDrawGraph(dagp, 'layout', cancerLayout); 
% 	title(sprintf('%f %f (%i %i)',prp,logQp,acyclic(dagp),  accept));
% 	keyboard;
	
	if( accept )
		pr = prp;
%		logPrior = logPriorp;
%		logMargLik = logMargLikp;
		logQ = logQp;
		dag = dagp;
	end	
	
	samples{si} = dag;
	
	numAccepts = numAccepts + accept;
	numRejects = numRejects + (1-accept);
	acceptanceRate(si) = numAccepts/numRejects;
	
	if mod(si,1000)==0,
		fprintf('%i\n',si);
	end
end


function logPrior = uniformPrior( dag )

if ~acyclic(dag)
	logPrior = -Inf;
else
	logPrior = log(1);
end

function [dag lp] = sampleDagFromEdgeMarginals( edgeProb )

lp = 0;
dag = zeros(size(edgeProb));
for ei=1:length(edgeProb)^2
	if rand<edgeProb(ei)
		dag( ei ) = 1;
		lp = lp + log( edgeProb(ei) );
	else
		lp = lp + log( 1-edgeProb(ei) );
	end
end

function ml = logMargLikDag( dag, data, clamped, sz )

ml = 0;
for ni=1:length(dag)
	pa = parents(dag, ni);
	ml = ml + logMargLikMultiFamily( data, clamped, pa, ni, sz, 1, 'perfect' );
end
