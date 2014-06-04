function [samples diagnostics] = sampleOrders( allFamilyLogScore, varargin )

[ nSamples, burnin, thinning, verbose, fixedComputeTime ] = process_options(varargin, 'nSamples', 5000, ...
	'burnin', 100, 'thinning', 2, 'verbose', false, 'fixedComputeTime', Inf );

nRequestedSamples = nSamples;
nSamples = nRequestedSamples*thinning + burnin;

nNodes = size(allFamilyLogScore, 1);

nActualSamples = 0;
nAccepts = 0;
nRejects = 0;

acceptanceRate = zeros(1, nRequestedSamples);

orderIndex = 1; 
samples = [];
samples.nNodes = size(allFamilyLogScore, 1);
samples.HT = java.util.Hashtable(2^15);
samples.order = zeros(1, nRequestedSamples);
samples.order2OrderHT = java.util.Hashtable(2^15);

timing = zeros(1, nRequestedSamples);

if verbose
	figure(100); clf;
	plot(0,0,'.'); hold on;
end

order = randperm(nNodes); % starting sample
score = logMargLikOrder( order, allFamilyLogScore );

plotPeriod = 250;

tic;

lastARVal = 0;

for si = 1:nSamples

	% proposal: swap two indices of order
	porder = order;
	prop = randperm(nNodes);
	T = porder(prop(1));
	porder(prop(1)) = porder(prop(2));
	porder(prop(2)) = T;
	pscore = logMargLikOrder( porder, allFamilyLogScore );

	alpha = exp( pscore - score );
	accept = rand<alpha;
	
	if( accept )
		order = porder;
		score = pscore;
	end			
		
	nAccepts = nAccepts + accept;
	nRejects = nRejects + (1-accept);
	if si > burnin && mod(si-burnin-1, thinning)==0
        nActualSamples = nActualSamples + 1; 
		
		orderKey = char(order); % never 0 so no \0 problems
		orderValue = samples.HT.get(orderKey);
		if isempty(orderValue)
			count = 1;
			ind = orderIndex; % meaning of order is overloaded here
			orderIndex = orderIndex + 1;
			
			samples.order2OrderHT.put( ind, orderKey );
		else
			count = orderValue(1) + 1;
			ind = orderValue(2);
		end
		samples.order(nActualSamples) = ind;
		samples.HT.put( orderKey, [count ind] );
		
		timing(nActualSamples) = toc;
        acceptanceRate(nActualSamples) =  nAccepts/(nRejects+nAccepts);		
	end
	
	timing(si) = toc;
	
	if verbose && mod(si, plotPeriod)==0,
		ar = nAccepts/(nRejects+nAccepts)*100;

		if mod(si,1000)==0
			fprintf('Sample %i of %i [AR: %0.2f]\n',si, nSamples, ar);
        end
        
		figure(100);
		plot([si-plotPeriod si], [lastARVal ar], '-xr'); hold on;
		axis([(si-1000) si+500 0 100]);
		title(sprintf('t=%.2f',timing(si)));
		drawnow;
				
		lastARVal = ar;		
	end
	
	if toc>fixedComputeTime
		fprintf('fixed amount of time %fs exceeded\n', fixedComputeTime);
		fprintf('%i samples taken\n', nActualSamples);
		break;
	end
	
end

samples.nSamples = nActualSamples;
samples.order = samples.order(1:nActualSamples);

diagnostics.nAccepts = nAccepts;
diagnostics.nRejects = nRejects;
diagnostics.acceptanceRate = acceptanceRate(1:nActualSamples);
diagnostics.timing = timing(1:nActualSamples);
