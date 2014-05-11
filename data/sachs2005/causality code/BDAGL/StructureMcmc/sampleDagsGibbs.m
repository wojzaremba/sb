function [samples, diagnostics] = sampleDagsGibbs(logPriorFn, allFamilyLogMargLik, varargin)

[ nSamples, burnin, thinning, verbose, initialDag, maxFanIn, fixedComputeTime, restartPeriod ] = ...
	process_options(varargin, 'nSamples', 5000, ...
	'burnin', 50, 'thinning', 2, 'verbose', false, 'initialDag', [], ...
	'maxFanIn', size(allFamilyLogMargLik,1)-1, 'fixedComputeTime', Inf, ...
	'restartPeriod', 50 );

tic

if thinning<1, thinning=1; end

nRequestedSamples = nSamples;
nSamples = nRequestedSamples*thinning;
if restartPeriod>0
	nSamples = nSamples + floor(nRequestedSamples/restartPeriod)*burnin;
else
	nSamples = nSamples + burnin;
end

nNodes = size(allFamilyLogMargLik,1);

if isempty(initialDag)
	dag = mk_rnd_dag(nNodes, maxFanIn); % random starting point
else
    dag = initialDag;
end

familyK = zeros(1,nNodes);
familyLML = zeros(1,nNodes);
for ni=1:nNodes
	pa = find(dag(:,ni));
	k = sum(2.^(pa-1));
	familyK(ni) = k;
	familyLML(ni) = allFamilyLogMargLik(ni, k+1);
end

dagPrior = logPriorFn( dag );

% reachability graph
AB = reachability_graph(dag');

nActualSamples = 0;
nAccepts = 0;
nRejects = 0;
acceptanceRate = zeros(1, nRequestedSamples);

orderIndex = 1; 
samples = [];
samples.nNodes = size(allFamilyLogMargLik,1);
samples.HT = java.util.Hashtable(2^15);
samples.order = zeros(1, nRequestedSamples);
samples.order2DagHT = java.util.Hashtable(2^15);

timing = zeros(1, nRequestedSamples);

if verbose
    figure(100); clf; subplot(3,1,1);
    plot(0,0,'.'); hold on;
end

sites = ones(nNodes);
sites = sites - diag(ones(1,nNodes));
[sitesI sitesJ] = find(sites);

lastARVal = 1;
plotPeriod = 250;
runningSum = zeros(nNodes);
windowedRunningSum = zeros(nNodes);
nWindowedSamples = 0;

restartDags = {};
restartDags{1} = dag;

Gbar = 1-dag;

nSamplesBurned = 0;

skipper = 0;
for si=1:nSamples

	perm = randperm(length(sitesI));
		
	for gi=1:length(sitesI)
		source = sitesI(perm(gi));
		dest = sitesJ(perm(gi));
						
		% check to see if the toggle is a valid move (ie. if it creates a
		% cycle or not)
		cyclicity = -Inf;
		if bitget(familyK(dest), source) % edge already exists
			cyclicity = 0; % edge deletion - always kosher
		else % edge does not exist
			
			GbarL = Gbar-AB;
			if( GbarL(source,dest)==1 ) % legal
				cyclicity = 0;
			end
			
		end
			
		dagp = dag; dagp( source, dest ) = 1 - dagp( source, dest );

		k = bitxor(familyK(dest), 2^(source-1));
		familyLMLp = allFamilyLogMargLik(dest, k+1);
					
		dist = [familyLML(dest) familyLMLp + cyclicity];
		dist = dist-logadd_sum(dist);
		dist = exp(dist);
				
		if rand>dist(1) % change chosen
			
 			dag = dagp;
			Gbar = 1-dag;
			% update ancestor matrix
			if bitget(familyK(dest), source) % edge already exists
				AB = do_removal(AB, source, dest, dag); % must  be the updated dag
			else % edge does not exist
				AB = do_addition(AB, source, dest, dag);
			end
						
% 			dagLML = dagLMLp;
			familyK(dest) = k;
			familyLML(dest) = familyLMLp;
		end
	end

	if nSamplesBurned >= burnin && mod(si-1, thinning)==0
		nActualSamples = nActualSamples + 1; 
		timing(nActualSamples) = toc;
        acceptanceRate(nActualSamples) =  1;%nAccepts/(nRejects+nAccepts);		
		
		dagKey = dag2char(dag);
		dagValue = samples.HT.get(dagKey);
		if isempty(dagValue)
			count = 1;
			ind = orderIndex;
			orderIndex = orderIndex + 1;
			
			samples.order2DagHT.put( ind, dagKey );
		else
			count = dagValue(1) + 1;
			ind = dagValue(2);
		end
		samples.order(nActualSamples) = ind;
		samples.HT.put( dagKey, [count ind] );

		runningSum = runningSum + dag;
		windowedRunningSum = windowedRunningSum + dag;
		nWindowedSamples = nWindowedSamples + 1;
	else
		nSamplesBurned = nSamplesBurned + 1;
	end


	if verbose && mod(si, plotPeriod)==0
		ar = 1 * 100;
		
        if mod(si,1000)==0
			fprintf('Sample %i of %i [AR: %0.2f]\n',si, nSamples, ar);
		end
        
		subplot(3,1,1);
        title(sprintf('Time elapsed: %.2f, Max allowed time: %.2f', toc, fixedComputeTime));
		figure(100); 
		plot([si-plotPeriod si], [lastARVal ar], 'xr'); hold on;
		axis([(si-2000) si+500 0 100]);
		
		lastARVal = ar;
		
		if nActualSamples>0
			subplot(3,1,2);
			imagesc(runningSum/nActualSamples,[0 1]);
			axis('square');

			if nWindowedSamples>0
				subplot(3,1,3);
				imagesc(windowedRunningSum/nWindowedSamples,[0 1]);
				axis('square');
				windowedRunningSum(:) = 0;
				nWindowedSamples = 0;
			end
		end
		
		drawnow;
	end
	
	if restartPeriod>0 && nActualSamples>skipper && mod(nActualSamples, restartPeriod)==0
		% random restart
		nSamplesBurned = 0; % do burnin again
		skipper = skipper + restartPeriod;
		
		dag = mk_rnd_dag(nNodes, maxFanIn); % random starting point

        restartDags{length(restartDags)+1} = dag;
        
		for ni=1:nNodes
			pa = find(dag(:,ni));
			k = sum(2.^(pa-1));
			familyK(ni) = k;
			familyLML(ni) = allFamilyLogMargLik(ni, k+1);
		end

		dagPrior = logPriorFn( dag );
		windowedRunningSum = zeros(nNodes);
		nWindowedSamples = 0;

		% reachability graph
		AB = reachability_graph(dag');
	end	
	
	if toc>fixedComputeTime
		fprintf('fixed amount of time %fs exceeded\n', fixedComputeTime);
		fprintf('%i samples taken\n', nActualSamples);
		break;
	end
end

samples.nSamples = nActualSamples;
samples.order = samples.order(1:nActualSamples);

diagnostics.restartDags = restartDags;
diagnostics.nAccepts = nAccepts;
diagnostics.nRejects = nRejects;
diagnostics.acceptanceRate = acceptanceRate(1:nActualSamples);
diagnostics.timing = timing(1:nActualSamples);


function A = do_addition(A, i, j, dag)

A(j,i) = 1; % i is an ancestor of j
anci = find(A(i,:));
if ~isempty(anci)
	A(j,anci) = 1; % all of i's ancestors are added to Anc(j)
end
ancj = find(A(j,:));
descj = find(A(:,j));
if ~isempty(ancj)
	for k=descj(:)'
		A(k,ancj) = 1; % all of j's ancestors are added to each descendant of j
	end
end

%%%%%%%%%%%
function A = do_removal(A, i, j, dag)

% find all the descendants of j, and put them in topological order

% SML: originally Kevin had the next line commented and the %* lines
% being used but I think this is equivalent and much less expensive
% I assume he put it there for debugging and never changed it back...?
descj = find(A(:,j));
%*  R = reachability_graph(dag);
%*  descj = find(R(j,:));

order = topological_sort(dag);

% SML: originally Kevin used the %* line but this was extracting the
% wrong things to sort
%* descj_topnum = order(descj);
[junk, perm] = sort(order); %SML:node i is perm(i)-TH in order
descj_topnum = perm(descj); %SML:descj(i) is descj_topnum(i)-th in order

% SML: now re-sort descj by rank in descj_topnum
[junk, perm] = sort(descj_topnum);
descj = descj(perm);

% Update j and all its descendants
A = update_row(A, j, dag);
for k = descj(:)'
	A = update_row(A, k, dag);
end

%%%%%%%%%%%

function A = update_row(A, j, dag)

% We compute row j of A
A(j, :) = 0;
ps = parents(dag, j);
if ~isempty(ps)
	A(j, ps) = 1;
end
for k=ps(:)'
	anck = find(A(k,:));
	if ~isempty(anck)
		A(j, anck) = 1;
	end
end
