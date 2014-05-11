function [Gmin_adjMatrix,scores,evals,dags] = DAGsearch(X,maxIter,restartVal,complexityFactor,discrete,clamped,varargin)
% Inputs:
%   X(instance,feature)
%   maxIter - maximum number of family evaluations
%   restartVal - probability of random restart after each step
%   complexityFactor - weight of free parameter term
%     (log(n)/2 == BIC, 1 == AIC)
%     ** use -1 to use marginal likelihood
%   discrete - set to 0 for continuous data, 1 for discrete data
%   clamped(instance,feature) - 0 if unclamped, 1 if clamped
%   PP(feature1,feature2) - 1 if we consider feature1 to be a possible parent of
%       feature 2, 0 if this is disallowed
%   dag (optional) - if present, starts from this initial dag, and returns
%       instead of restarting (used by hybrid order/dag-search method)
%
% Outputs:
%   Gmin_adjMatrix - adjacency matrix for the highest scoring structure
%   scores - scores after each step
%   evals - number of family evaluations after each step
%   dags - adjacnecy matrices after each step

global mlParams;

% tiebreaking: 0=deterministic, 1=random
% saveAsYouGo: a filename where the dag will be saved after each iteration
[verbose, mlParams, fixedComputeTime, dag, PP, ...
    tiebreaking, saveAsYouGo, printStatusFreq ] = process_options(varargin, 'verbose', 1, 'mlParams', [], 'fixedComputeTime', Inf,  ...
    'initialDag', [], 'PP', [], 'tiebreaking', 1, 'saveAsYouGo', [], 'printStatusFreq', 1 );

if ~isempty(saveAsYouGo)
    saveFreq = 10;
    fprintf('using save frequency of %i iteration\n', saveFreq);
end


% it's impossible to build an ADTree for a many-variable dataset (ex. 50 nodes with 200 datapoints) so
% instead scoring must be done the old fashioned way

if complexityFactor==-1 && isempty(mlParams)
    error('Parameter ''mlParams'' must be suplied to compute the marginal likelihood');
end

dags = {}; % don't save the history

doPlot = 0;
[n,p] = size(X);
restart = 1;
Gmin_score = inf;
totalEvals = 0;
evals(1) = 0;
scores(1) = inf;
dags{1} = ones(p);
Ind = 2;
iter = 0;

if isempty(PP)
   PP = ones(p); 
end


tic;

% fan-in bound (not recommended unless you are using tabular CPDs)
K = inf;

while evals(end) < maxIter
    drawnow;

    iter = iter + 1;

    if restart == 1
        % Restart Case

        if isempty(dag)
            % Generate a New Candidate

            % this has to be overidden to handle impossible families
            % this initial point generation procedure can get the algorithm stuck from scratch
    %        adjMatrix = zeros(p); % empty dag
            
            % Randomly add edges to an empty graph until you make a cycle
            % or make p^2 attempts at adding an edge
            adjMatrix = zeros(p);
            loops = 0;
            while ~cycles(adjMatrix)
                i = ceil(rand*p);
                j = ceil(rand*p);
                
                if isfield(mlParams, 'nInterventions') && j<=mlParams.nInterventions
                    continue;
                end
                
                if i ~= j && adjMatrix(i,j) == 0 && adjMatrix(j,i) == 0 && PP(i,j)==1
                    adjMatrix(i,j) = 1;

                    % test to see if it's an "impossible" family (ie. its score is Inf)
                    childScore = EvaluateFamily(X,adjMatrix,complexityFactor,discrete,clamped,j);

                    if childScore==Inf,
                        adjMatrix(i,j) = 0;
                    end
                elseif loops > p^2
                    break;
                else
                    loops = loops + 1;
                    continue;
                end
            end
            % Break the violation that caused the loop to exit
            if cycles(adjMatrix)
                adjMatrix(i,j) = 0;
            end
            %clf;
            %drawGraph(adjMatrix);
            %pause;
        else
            if verbose
                fprintf('Warm-starting\n');
            end
            adjMatrix = dag;
        end


        % Compute Statistics

        graphScores = EvaluateGraph(X,adjMatrix,complexityFactor,discrete,clamped);

        % Set Candidate as Local Min
        Lmin_score = sum(graphScores);
        Lmin_adjMatrix = adjMatrix;

        % Compare to Global Min

        if Lmin_score < Gmin_score
            Gmin_score = Lmin_score;
            Gmin_adjMatrix = Lmin_adjMatrix;
        end

        % Update Counters
        evals(Ind) = evals(Ind-1)+1;
        scores(Ind) = inf;
%        dags{Ind} = ones(p);
        Ind = Ind+1;
        evals(Ind) = evals(Ind-2) + p;
        scores(Ind) = sum(graphScores);
%        dags{Ind} = sparse(adjMatrix);
        Ind = Ind+1;

        % Update state indicators
        atLocalMin = 0;
        restart = 0;

    else
        % 1st Iter after Restart

        atLocalMin = 1;

        if restart == 0
            % Test all deletions, additions, reversals

            if verbose>1,    fprintf('Evaluating Deletions\n'); end
            [delta_graphScores_del delEvals] = EvaluateDeletions(X,adjMatrix,complexityFactor,graphScores,discrete,clamped);
            if verbose>1,    fprintf('Evaluating Additions\n'); end
            [delta_graphScores_add addEvals] = EvaluateAdditions(X,adjMatrix,complexityFactor,graphScores,discrete,clamped,PP,K);
            if verbose>1,    fprintf('Evaluating Reversals\n'); end
            [delta_graphScores_revJ delta_graphScores_revI revEvals] = ...
                EvaluateReversals(X,adjMatrix,complexityFactor,...
                graphScores,discrete,clamped,PP,K,delta_graphScores_del);
        else
            % Update the scores of deletions, additions, reversals
            % (based on old scores and changes in graph)

            if verbose>1,    fprintf('Updating Deletions\n'); end
            [delta_graphScores_del delEvals] = UpdateDeletions(X,adjMatrix,...
                complexityFactor,graphScores,discrete,clamped,delta_graphScores_del,changed);
            if verbose>1,    fprintf('Updating Additions\n'); end
            [delta_graphScores_add addEvals] = UpdateAdditions(X,adjMatrix,...
                complexityFactor,graphScores,discrete,clamped,PP,K,delta_graphScores_add,changed);
            if verbose>1,    fprintf('Updating Reversals\n'); end
            [delta_graphScores_revJ delta_graphScores_revI revEvals] = ...
                UpdateReversals(X,adjMatrix,complexityFactor,...
                graphScores,discrete,clamped,PP,K,delta_graphScores_del,...
                delta_graphScores_revJ,delta_graphScores_revI,changed);
        end

        % Find Move that Decreases the Score the most

        min_del = min(delta_graphScores_del(:));
        delPos = find(delta_graphScores_del(:)==min_del);
        if tiebreaking==0
            delPos = delPos(1);
        else
            delPos = delPos(ceil(rand*length(delPos))); % break ties at random
        end
     
        min_add = min(delta_graphScores_add(:));
        addPos = find(delta_graphScores_add(:)==min_add);
        if tiebreaking==0
            addPos = addPos(1);
        else
            addPos = addPos(ceil(rand*length(addPos))); % break ties at random
        end
        
        combinedRevScores = delta_graphScores_revI+delta_graphScores_revJ;
        min_rev = min(combinedRevScores(:));
        revPos = find(combinedRevScores(:)==min_rev);
        if tiebreaking==0
            revPos = revPos(1);
        else
            revPos = revPos(ceil(rand*length(revPos)));  % break ties at random
        end

        if min_del <= min_add
            if min_del <= min_rev
                op = -1;
            else
                op = 0;
            end
        else
            if min_add <= min_rev
                op = 1;
            else
                op = 0;
            end
        end

        % Update Adjacency Matrix and Statistics

        if op == -1
            % Deletion
            [i j] = ind2sub(p,delPos);

            if verbose>1
                fprintf('OP: Delete %i->%i\n', i,j );
            end

            adjMatrix(i,j) = 0;
            changed = j; % delta_graphScores for j's family are obsolete
            graphScores(j) = graphScores(j) + delta_graphScores_del(i,j);
        elseif op == 1
            % Addition
            [i j] = ind2sub(p,addPos);

            if verbose>1
                fprintf('OP: Add %i->%i\n', i,j );
            end

            adjMatrix(i,j) = 1;
            changed = j; % delta_graphScores for i's family are obsolete
            graphScores(j) = graphScores(j) + delta_graphScores_add(i,j);
        else
            % Reversal
            [i j] = ind2sub(p,revPos);
            
            if verbose>1
                fprintf('OP: Reverse %i->%i\n', i,j );
            end

            adjMatrix(i,j) = 0;
            adjMatrix(j,i) = 1;
            changed = [i j]; % delta_graphScores i+j's families are obsolete
            graphScores(j) = graphScores(j) + delta_graphScores_revJ(i,j);
            graphScores(i) = graphScores(i) + delta_graphScores_revI(i,j);
        end

        % Check for local/global decrease

        configScore = sum(graphScores);

        if configScore < Lmin_score
            Lmin_score = configScore;
            Lmin_adjMatrix = adjMatrix;
            atLocalMin = 0;
            if Lmin_score < Gmin_score
                Gmin_score = Lmin_score;
                Gmin_adjMatrix = Lmin_adjMatrix;
            end
        end

        % VERIFICATION CODE
        if 0
            tempgraphScores = EvaluateGraph(X,adjMatrix,complexityFactor,discrete,clamped);
            fprintf('Difference between correct scores and maintained scores:\n');
            sum(abs(tempgraphScores-graphScores)) > 1e-4
            if sum(abs(tempgraphScores-graphScores)) > 1e-4
                pause;
            end
        end

        % Update Counters
        evals(Ind) = evals(Ind-1) + delEvals + addEvals + revEvals;
        scores(Ind) = sum(graphScores);
%        dags{Ind} = sparse(Lmin_adjMatrix);
        Ind = Ind+1;

        restart = -1;
    end

    if doPlot
        clf;
        subplot(1,2,1);
        drawGraph(Lmin_adjMatrix);
        subplot(1,2,2);
        drawGraph(Gmin_adjMatrix);
        pause;
    end

    %drawnow;
    %fprintf('Saving\n');
    %save(sprintf('results/news%d_iter%d.mat',discrete,iter));

	% Output Iteration Log
	if mod(iter,printStatusFreq)==0
		fprintf('%f DAGsearch: It %d, Evals = %d, Lmin = %.3f, Gmin = %.3f',toc, iter,evals(end),Lmin_score,Gmin_score);
		if atLocalMin
			fprintf(' (Found Local Minimum)\n');
		elseif restartVal > 0 && rand < restartVal % First condition avoid changing seed
			fprintf(' (Randomly Restarting)\n');
		else
			fprintf('\n');
		end
	end

	% Set restart indicator to 1 if we are at a local minimum, or
	%   if we are doing a random restart
	if atLocalMin
		restart = 1;
	elseif restartVal > 0 && rand < restartVal % First condition avoid changing seed
		restart = 1;
	end    

	if( toc>fixedComputeTime )
		break;
    end

    if ~isempty(dag) && restart == 1
        if verbose
            fprintf('Found local minimum, returning\n');
        end
        fprintf('would break, but dan disabled it\n');
    end
    
    if ~isempty(saveAsYouGo) && mod(iter,saveFreq)==0
        dagCurrent = Gmin_adjMatrix;
        time = toc;
        nIters = iter;
        save(saveAsYouGo, 'dagCurrent', 'time', 'nIters' );
    end

end

clear mlParams;

end

function [familyScore] = EvaluateFamily(X,adjMatrix,complexityFactor,discrete,clamped,i)
% Evaluate pi(i,pa(i))

parents = find(adjMatrix(:,i))';
global mlParams;
if ~isempty(mlParams)
    % data (X) is stored as the transpose to what BNSL uses
    
    familyScore = 0;

    if isfield(mlParams, 'aflml')
        % easy-street!
        
        index = sum(2.^(parents-1))+1;
        familyScore = -mlParams.aflml(i,index);

    else
        
        if isfield(mlParams, 'impossibleFamilyMask')
            ind = sum(2.^(parents-1))+1;
            if ~mlParams.impossibleFamilyMask(i, ind)
                familyScore = Inf;
            end
        else % hack! handle uncertain interventions
            if length(parents)>mlParams.maxFanIn || ( i<=mlParams.nInterventions && length(parents)>0 )
                familyScore = Inf;
            else
                uncertainParents = find(adjMatrix(1:mlParams.nInterventions, i));
                if length(uncertainParents)>1
                    familyScore = Inf;
                end
            end
        end

        if ~isinf(familyScore)
            if isfield(mlParams, 'nInterventions') && i<=mlParams.nInterventions
                % intervention node, don't waste computation
                familyScore = log(1);
            else
                alpha = 1;
                familyScore = -logMargLikMultiFamilySlow(X(mlParams.intervention.clampedMask(i,:)==0, :)', X(mlParams.intervention.clampedMask(i,:)==1, :)', parents, i, mlParams.nodeArity, alpha, mlParams.intervention);
            end
        end
    end
else
    
    % Check node type if not all the same
    if ~isscalar(discrete)
        CPDtype = discrete(i);
    else
        CPDtype = discrete;
    end

    if CPDtype == 1 % Logistic
        Xsub = [ones(length(X(clamped(:,i)==0,1)),1) X(clamped(:,i)==0,parents)];
        ysub = X(clamped(:,i)==0,i);
        params = L2LogReg_IRLS(Xsub,ysub);
        familyScore = score(LLoss(params,Xsub,ysub),sum(abs(params) >= 1e-4),complexityFactor);
    elseif CPDtype == 0 % Gaussian
        XX = X(clamped(:,i)==0,parents)'*X(clamped(:,i)==0,parents);
        Xy = X(clamped(:,i)==0,parents)'*X(clamped(:,i)==0,i);
        yy = X(clamped(:,i)==0,i)'*X(clamped(:,i)==0,i);

        %params = XX\Xy;
        R = chol(XX);
        params = R \ (R'\Xy);

        familyScore = score(GLoss(XX,Xy,yy,params),sum(adjMatrix(:,i)),complexityFactor);
    else % Multinomial Logistic (slow...)
        nStates = CPDtype;
        options.Display = 'none';
        if isscalar(discrete)
            discrete = repmat(discrete,[size(X,2) 1]);
        end
        % To make classes exchangeable, regress on dummy variables
        Xsub = [ones(length(X(clamped(:,i)==0,1)),1) makeDummy(X(clamped(:,i)==0,parents),discrete(parents))];
        ysub = X(clamped(:,i)==0,i);
        p = size(Xsub);
        params_init = zeros(size(Xsub,2)*(nStates-1),1);
        params = minFunc(@SoftmaxLoss2,params_init,options,Xsub,ysub,nStates);
        familyScore = score(SoftmaxLoss2(params,Xsub,ysub,nStates),sum(abs(params) >= 1e-4),complexityFactor);
    end
end
end

function [graphScores] = EvaluateGraph(X,adjMatrix,complexityFactor,discrete,clamped)
p = length(adjMatrix);
graphScores = zeros(1,p);
for i = 1:p
    %fprintf('Evaluating family of %d\n',i);
    graphScores(i) = EvaluateFamily(X,adjMatrix,complexityFactor,discrete,clamped,i);
end
end

function [delta_scores,evals] = EvaluateDeletions(X,adjMatrix,complexityFactor,graphScores,discrete,clamped)
p = length(adjMatrix);
delta_scores = zeros(p);
evals = 0;
for i = 1:p
    for j = 1:p
        if adjMatrix(i,j) == 1
            % Evaluate deleting i => j
            %fprintf('Evaluating deletion of (%d,%d)\n',i,j);
            adjMatrix_del = adjMatrix;
            adjMatrix_del(i,j) = 0;
            delta_scores(i,j) = ....
                EvaluateFamily(X,adjMatrix_del,complexityFactor,discrete,clamped,j) ...
                - graphScores(j);
            evals = evals+1;
        end
    end
end
end

function [delta_scores,evals] = UpdateDeletions(X,adjMatrix,complexityFactor,...
    graphScores,discrete,clamped,delta_scores,changed)
p = length(adjMatrix);
evals = 0;
for i = 1:p
    for j = changed
        if adjMatrix(i,j) == 1
            % Evaluate deleting i => j
            %fprintf('Evaluating deletion of (%d,%d)\n',i,j);
            adjMatrix_del = adjMatrix;
            adjMatrix_del(i,j) = 0;
            delta_scores(i,j) = ....
                EvaluateFamily(X,adjMatrix_del,complexityFactor,discrete,clamped,j) ...
                - graphScores(j);
            evals = evals+1;
        else
            delta_scores(i,j) = 0; % This edge may have been deleted
        end
    end
end
end

function [delta_scores,evals] = EvaluateAdditions(X,adjMatrix,complexityFactor,graphScores,discrete,clamped,PP,K)
p = length(adjMatrix);
delta_scores = zeros(p);
evals = 0;
for i = 1:p
    for j = 1:p
        if PP(i,j) == 1  && adjMatrix(i,j) == 0 && adjMatrix(j,i) == 0 && i ~= j 
%            isc = cycles(adjMatrix_add);
            isc = isCyclic_addEdge(adjMatrix,i,j);
            if ~isc % sum(adjMatrix_add(:,j)) <= K % fan in check unecessary, dan's code in EvalFam handles it
                % Evaluate adding i => j
                %fprintf('Evaluating addition of (%d,%d)\n',i,j);
                adjMatrix(i,j) = 1;
                delta_scores(i,j) = ...
                    EvaluateFamily(X,adjMatrix,complexityFactor,discrete,clamped,j) ...
                    - graphScores(j);
                evals = evals+1;
                adjMatrix(i,j) = 0; % reset adj matrix
            end
        end
    end
end
end

function [delta_scores,evals] = UpdateAdditions(X,adjMatrix,complexityFactor,...
    graphScores,discrete,clamped,PP,K,delta_scores_old,changed)
p = length(adjMatrix);
delta_scores = zeros(p);
evals = 0;
for i = 1:p
    for j = 1:p
        if PP(i,j) == 1 && i ~= j && adjMatrix(i,j) == 0 && adjMatrix(j,i) == 0
            %adjMatrix_add = adjMatrix;
            %adjMatrix_add(i,j) = 1;
            isc = isCyclic_addEdge(adjMatrix,i,j);
            
            if ~isc %sum(adjMatrix_add(:,j)) <= K && ~cycles(adjMatrix_add)
                % Evaluate adding i => j
                %fprintf('Evaluating addition of (%d,%d)\n',i,j);
                adjMatrix(i,j) = 1;
%                if ismember(j,changed) || delta_scores_old(i,j) == 0
                if any(j==changed) || delta_scores_old(i,j) == 0
                    delta_scores(i,j) = ...
                        EvaluateFamily(X,adjMatrix,complexityFactor,discrete,clamped,j) ...
                        - graphScores(j);
                    evals = evals+1;
                else
                    delta_scores(i,j) = delta_scores_old(i,j);
                end
                adjMatrix(i,j) = 0; % reset adjmatrix
            end
        end
    end
end
end



function [delta_scoresj,delta_scoresi,evals] = EvaluateReversals(X,adjMatrix,...
    complexityFactor,graphScores,discrete,clamped,PP,K,delta_scores_del)
p = length(adjMatrix);
params = cell(p);
delta_scoresj = zeros(p);
delta_scoresi = zeros(p);
evals = 0;
for i = 1:p
    for j = 1:p
        if adjMatrix(i,j) == 1 && PP(j,i) == 1
            isc = isCyclic_revEdge(adjMatrix,i,j);
            if ~isc % sum(adjMatrix_add(:,j)) <= K % fan in check unecessary, dan's code in EvalFam handles it
                % Evaluate reversing i => j
                %fprintf('Evaluating reversal of (%d,%d)\n',i,j);
                
                adjMatrix(i,j) = 0;
                adjMatrix(j,i) = 1;
                
                delta_scoresj(i,j) = delta_scores_del(i,j);
                delta_scoresi(i,j) = ...
                    EvaluateFamily(X,adjMatrix,complexityFactor,discrete,clamped,i)...
                    - graphScores(i);
                evals = evals+1;

                adjMatrix(i,j) = 1;
                adjMatrix(j,i) = 0;
            end
        end
    end
end
end

function [delta_scoresj,delta_scoresi,evals] = UpdateReversals(X,adjMatrix,...
    complexityFactor,graphScores,discrete,clamped,PP,K,delta_scores_del,...
    delta_scoresj_old,delta_scoresi_old,changed)
p = length(adjMatrix);
params = cell(p);
delta_scoresj = zeros(p);
delta_scoresi = zeros(p);
evals = 0;
for i = 1:p
    for j = 1:p
        if adjMatrix(i,j) == 1 && PP(j,i) == 1
            isc = isCyclic_revEdge(adjMatrix,i,j);
            if ~isc % sum(adjMatrix_add(:,j)) <= K % fan in check unecessary, dan's code in EvalFam handles it
                if any(i==changed) || any(j==changed) || ...
                        (delta_scoresj_old(i,j) == 0 && delta_scoresi_old(i,j) == 0)
%                 if ismember(i,changed) || ismember(j,changed) || ...
%                         (delta_scoresj_old(i,j) == 0 && delta_scoresi_old(i,j) == 0)
                    % Evaluate reversing i => j
                    %fprintf('Evaluating reversal of (%d,%d)\n',i,j);
                    adjMatrix(i,j) = 0;
                    adjMatrix(j,i) = 1;

                    delta_scoresj(i,j) = delta_scores_del(i,j);
                    delta_scoresi(i,j) = ...
                        EvaluateFamily(X,adjMatrix,complexityFactor,discrete,clamped,i)...
                        - graphScores(i);
                    evals = evals+1;

                    adjMatrix(i,j) = 1;
                    adjMatrix(j,i) = 0;
                else
                    delta_scoresj(i,j) = delta_scoresj_old(i,j);
                    delta_scoresi(i,j) = delta_scoresi_old(i,j);
                end

            end
        end
    end
end
end



% Returns 1 if the graph has cycles
function [c] = cycles(adjMatrix)
p = length(adjMatrix);
c = sum(diag((sparse(adjMatrix+eye(p)))^p) == ones(p,1)) ~= p;
end