function [samples, diagnostics, runningSum] = sampleDags(logPriorFn, allFamilyLogMargLik, varargin)

[ nSamples, burnin, thinning, verbose, initialDag,  ...
    globalFrac, edgeMarginals, gibbsFrac, maxFanIn, fixedComputeTime ] =...
    process_options(varargin, 'nSamples', 10000, ...
		    'burnin', 500, 'thinning', 2, 'verbose', false, 'initialDag', [], ...
		    'globalFrac', 0, 'edgeMarginals', [], 'gibbsFrac', 0, ...
		    'maxFanIn', -1, 'fixedComputeTime', Inf);

if globalFrac>0 && isempty(edgeMarginals)
    error('In order to use Dp/global jumps, must supply edgeMarginals argument');
end

nNodes = size(allFamilyLogMargLik,1);

if maxFanIn<0, maxFanIn = nNodes-1; end

localFrac = 1-(globalFrac + gibbsFrac);
jumpFracs = [globalFrac, gibbsFrac, localFrac];
disp('prob global/ gibbs/ local move')
jumpFracs = jumpFracs/sum(jumpFracs)

if thinning<=0, thinning = 1; end

tic

nRequestedSamples = nSamples;
nSamples = nRequestedSamples*thinning + burnin;

if isempty(initialDag)
    if isempty(edgeMarginals)
        dag = mk_rnd_dag(nNodes, maxFanIn); % random starting point
    else
        isCyclic = true; % start from a dag
        while isCyclic
            dag = sampleDagFromEdgeMarginals( edgeMarginals );
            if acyclic(dag)
                isCyclic = false;
            end
        end
    end
else
    dag = initialDag;
end

id = dag;

% We implement the fast acyclicity check described by P. Giudici and R. Castelo,
% "Improving MCMC model search for data mining", submitted to J. Machine Learning, 2001.

% SML: also keep descendant matrix C
use_giudici = 1;
if use_giudici
	[nbrs, ops, nodes, A] = mk_nbrs_of_digraph(dag);
else
	[nbrs, ops, nodes] = mk_nbrs_of_dag(dag);
	A = [];
end

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

% for status display
runningSum = zeros(nNodes);
windowedRunningSum = zeros(nNodes);
nWindowedSamples = 0;
lastARVal = 1;
plotPeriod = 250;

nGlobal = 0;
nGlobalAccepted = 0;

nLocal = 0;
nLocalAccepted = 0;

nGibbs = 0;
nGibbsAccepted = 0;

% gibbs-related
sites = ones(nNodes);
sites = sites - diag(ones(1,nNodes));
[sitesI sitesJ] = find(sites);

if verbose
    figure(100); clf;
	subplot(3,1,1);
    plot(0,0,'.'); hold on;
    ylabel('AR');
    xlabel('Iteration no.');
end

global ncyclic 
ncyclic = 0;
isReachabilityStale = true;
areNeighboursStale = true;
for si=1:nSamples
	
    jumpTypeRand = rand;
    
    if jumpTypeRand>jumpFracs(1)
        % gibbs or local
        if isReachabilityStale
            AB = reachability_graph(dag');
            isReachabilityStale = false;
        end
        
        if areNeighboursStale && jumpTypeRand>jumpFracs(2)
            [nbrs, ops, nodes, A] = mk_nbrs_of_digraph(dag, AB);
            areNeighboursStale = false;
        end
    end
    
	if jumpTypeRand<jumpFracs(1)
		% perform non-local step
		nGlobal = nGlobal + 1;

		[dagp logQp] = sampleDagFromEdgeMarginals( edgeMarginals );
		logMargLikp = logMargLikDag( dagp, allFamilyLogMargLik);
		
		[dag logQ] = sampleDagFromEdgeMarginals( edgeMarginals, dag );
		logMargLik = logMargLikDag( dag, allFamilyLogMargLik);
		
		[logPriorp isCyclic] = logPriorFn( dagp );
		[logPrior] = logPriorFn( dag );

		if isCyclic
			ncyclic=ncyclic+1;
		end
		
		prp = logMargLikp + logPriorp;
		pr = logMargLik + logPrior;

		alpha = exp( prp - pr ) * exp( logQ - logQp );

		accept = rand<alpha;
		
		if accept
			dag = dagp;
			nGlobalAccepted = nGlobalAccepted + 1;
            isReachabilityStale = true;
            areNeighboursStale = true;
		end
    elseif jumpTypeRand<jumpFracs(2)
        % perform gibbs sweep step
        
        nGibbs = nGibbs + 1;
        nGibbsAccepted = nGibbsAccepted + 1;
        
        familyK = zeros(1,nNodes);
        familyLML = zeros(1,nNodes);
        for ni=1:nNodes
            pa = find(dag(:,ni));
            k = sum(2.^(pa-1));
            familyK(ni) = k;
            familyLML(ni) = allFamilyLogMargLik(ni, k+1);
        end
        Gbar = 1 - dag;
        
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

%            dagp = dag; dagp( source, dest ) = 1 - dagp( source, dest );

            k = bitxor(familyK(dest), 2^(source-1));
            familyLMLp = allFamilyLogMargLik(dest, k+1);

            dist = [familyLML(dest) familyLMLp + cyclicity];
            dist = dist-logadd_sum(dist);
            dist = exp(dist);

            if rand>dist(1) % change chosen

%                 dag = dagp;
                dag( source, dest ) = 1 - dag( source, dest );
                Gbar( source, dest ) = 1 - Gbar( source, dest );

                % update ancestor matrix
                if bitget(familyK(dest), source) % edge already exists
                    AB = do_removal(AB, [], source, dest, dag); % must  be the updated dag
                else % edge does not exist
                    AB = do_addition(AB, [], source, dest, dag);
                end

                % 			dagLML = dagLMLp;
                familyK(dest) = k;
                familyLML(dest) = familyLMLp;
            end
            
            accept = 1; % always accept, gibbs!
        end
        
        isReachabilityStale = false;
        areNeighboursStale = true;
    else
		nLocal = nLocal + 1;
        
		[dag, nbrs, ops, nodes, A, accept] = take_step(dag, nbrs, ops, ...
			nodes, A, logPriorFn, allFamilyLogMargLik );
		
		if accept
			nLocalAccepted = nLocalAccepted + 1;
		end
	end
	
	nAccepts = nAccepts + accept;
	nRejects = nRejects + (1-accept);
	if si > burnin && mod(si-burnin-1, thinning)==0
        nActualSamples = nActualSamples + 1; 
		
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
		
		timing(nActualSamples) = toc;
        acceptanceRate(nActualSamples) =  nAccepts/(nRejects+nAccepts);
		
		runningSum = runningSum + dag;
		windowedRunningSum = windowedRunningSum + dag;
		nWindowedSamples = nWindowedSamples + 1;		
	end


	if verbose && mod(si, plotPeriod)==0
        ar = nAccepts/(nRejects+nAccepts) * 100;

        if mod(si,1000)==0
			fprintf('Sample %i of %i [AR: %0.2f]\n',si, nSamples, ar);
		end
        
		figure(100); 
		subplot(3,1,1);
		title(sprintf('Time elapsed: %.2f, Max allowed time: %.2f', toc, fixedComputeTime));
		plot([si-plotPeriod si], [lastARVal ar], '-xr'); hold on;
		axis([(si-2000) si+500 0 100]);
		drawnow;
		
		lastARVal = ar;
		
		if nActualSamples>0
			subplot(3,1,2);
			imagesc(runningSum/nActualSamples,[0 1]);
			axis('square');
            title(sprintf('Average over all %i samples taken', nActualSamples ));

			subplot(3,1,3);
			imagesc(windowedRunningSum/nWindowedSamples,[0 1]);
			axis('square');
			title(sprintf('Average over last %i samples', nWindowedSamples));
			windowedRunningSum(:) = 0;
			nWindowedSamples = 0;
		end		
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

diagnostics.nGlobal = nGlobal;
diagnostics.nGlobalAccepted = nGlobalAccepted;
diagnostics.nLocal = nLocal;
diagnostics.nLocalAccepted = nLocalAccepted;
diagnostics.nGibbs = nGibbs;
diagnostics.nGibbsAccepted = nGibbsAccepted;

runningSum = runningSum / nActualSamples;

%%%%%%%%%


function [new_dag, new_nbrs, new_ops, new_nodes, A,  accept] = ...
	take_step(dag, nbrs, ops, nodes, A, logPriorFn, allFamilyLogMargLik )

use_giudici = ~isempty(A);
if use_giudici
	[new_dag, op, i, j, new_A] =  pick_digraph_nbr(dag, nbrs, ops, nodes, A); % updates A
	[new_nbrs, new_ops, new_nodes] =  mk_nbrs_of_digraph(new_dag, new_A);
else
	d = sample_discrete(normalise(ones(1, length(nbrs))));
	new_dag = nbrs{d};
	op = ops{d};
	i = nodes(d, 1); j = nodes(d, 2);
	[new_nbrs, new_ops, new_nodes] = mk_nbrs_of_dag(new_dag);
end

bf = bayes_factor(dag, new_dag, op, i, j, logPriorFn, allFamilyLogMargLik);

%R = bf * (new_prior / prior) * (length(nbrs) / length(new_nbrs));
R = bf * (length(nbrs) / length(new_nbrs));
u = rand(1,1);
if u > min(1,R) % reject the move
	accept = 0;
	new_dag = dag;
	new_nbrs = nbrs;
	new_ops = ops;
	new_nodes = nodes;
else
	accept = 1;
	if use_giudici
		A = new_A; % new_A already updated in pick_digraph_nbr
	end
end


%%%%%%%%%

function bfactor = bayes_factor(old_dag, new_dag, op, i, j, logPriorFn, allFamilyLogMargLik)

paNew = find(new_dag(:,j));
paOld = find(old_dag(:,j));
kNew = sum(2.^(paNew-1));
kOld = sum(2.^(paOld-1));

LLnew = allFamilyLogMargLik(j, kNew+1);
LLold = allFamilyLogMargLik(j, kOld+1);

priorContribution = exp( logPriorFn(new_dag) - logPriorFn(old_dag) );

bf1 = exp(LLnew - LLold)*priorContribution;

if strcmp(op, 'rev')  % must also multiply in the changes to i's family
    paNew = find(new_dag(:,i));
    paOld = find(old_dag(:,i));
    kNew = sum(2.^(paNew-1));
    kOld = sum(2.^(paOld-1));

    LLnew = allFamilyLogMargLik(i, kNew+1);
    LLold = allFamilyLogMargLik(i, kOld+1);

    bf2 = exp(LLnew - LLold) * priorContribution;
else
	bf2 = 1;
end

bfactor = bf1 * bf2;


%%%%%%%% Giudici stuff follows %%%%%%%%%%


% SML: This now updates A as it goes from digraph it choses
function [new_dag, op, i, j, new_A] = pick_digraph_nbr(dag, digraph_nbrs, ops, nodes, A)

d = sample_discrete(normalise(ones(1, length(digraph_nbrs))));
%d = myunidrnd(length(digraph_nbrs),1,1);
i = nodes(d, 1); j = nodes(d, 2);
new_dag = digraph_nbrs(:,:,d);
op = ops{d};
new_A = update_ancestor_matrix(A, op, i, j, new_dag);


%%%%%%%%%%%%%%


function A = update_ancestor_matrix(A,  op, i, j, dag)

switch op
	case 'add',
		A = do_addition(A,  op, i, j, dag);
	case 'del',
		A = do_removal(A,  op, i, j, dag);
	case 'rev',
		A = do_removal(A,  op, i, j, dag);
		A = do_addition(A,  op, j, i, dag);
end


%%%%%%%%%%%%

function A = do_addition(A, op, i, j, dag)

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
function A = do_removal(A, op, i, j, dag)

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

function A = old_do_removal(A, op, i, j, dag)

% find all the descendants of j, and put them in topological order
% SML: originally Kevin had the next line commented and the %* lines
% being used but I think this is equivalent and much less expensive
% I assume he put it there for debugging and never changed it back...?
descj = find(A(:,j));
%*  R = reachability_graph(dag);
%*  descj = find(R(j,:));

order = topological_sort(dag);
descj_topnum = order(descj);
[junk, perm] = sort(descj_topnum);
descj = descj(perm);
% Update j and all its descendants
A = update_row(A, j, dag);
for k = descj(:)'
	A = update_row(A, k, dag);
end

%%%%%%%%%

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

%%%%%%%%

function A = init_ancestor_matrix(dag)

order = topological_sort(dag);
A = zeros(length(dag));
for j=order(:)'
	A = update_row(A, j, dag);
end
