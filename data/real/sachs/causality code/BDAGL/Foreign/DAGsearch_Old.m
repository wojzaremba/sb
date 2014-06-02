function [Gmin_adjMatrix,scores,evals,dags] = DAGSearch(X,maxIter,restartVal,warmStart,discrete,clamped,PP,fixedTime)
% author: mark. hacked by daniel feb 2007
% Inputs:
%   X(instance,feature)
%   maxIter - maximum number of family evaluations
%   restartVal - probability of random restart after each step
%   complexityFactor - weight of free parameter term
%     (log(n)/2 == BIC, 1 == AIC)
%   discrete - set to 0 for continuous data, 1 for discrete data,
%   clamped(instance,feature) - 0 if unclamped, 1 if clamped
%   PP(feature1,feature2) - 1 if we consider feature1 to be a parent of
%       feature 2, 0 if this is disallowed
%   dag (optional) - if present, starts from this initial dag, and returns
%       instead of restarting (used by hybrid order/dag-search method)
%
% Outputs:
%   Gmin_adjMatrix - adjacency matrix for the highest scoring structure
%   scores - scores after each step
%   evals - number of family evaluations after each step
%   dags - adjacnecy matrices after each step

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
complexityFactor = [];


tic; 

% fan-in bound (not recommended - creates a more bumpy 'energy surface'
if discrete == 0 || discrete == 1
	K = inf;
elseif discrete > 10
	K = discrete-10;
	discrete = 0;
elseif discrete < -10
	K = -(discrete+10);
	discrete = 1;
end

while evals(end) < maxIter
	drawnow;

	iter = iter + 1;

	if restart == 1
		% Restart Case

 		if isempty(warmStart)
			% Generate a New Candidate

			% Randomly add edges to an empty graph until you make a cycle
			% or make p^2 attempts at adding an edge
			adjMatrix = zeros(p);
			loops = 0;
			while ~cycles(adjMatrix)
				i = ceil(rand*p);
				j = ceil(rand*p);
				if i ~= j && adjMatrix(i,j) == 0 && adjMatrix(j,i) == 0
					adjMatrix(i,j) = 1;

					% Test fan-in bound and whether addition is legal
					if sum(adjMatrix(:,j)) > K %|| PP(i,j) == 0
						break;
					end
				elseif loops > p^2
					break;
				else
					loops = loops + 1;
					continue;
				end
			end
			% Break the violation that caused the loop to exit
			adjMatrix(i,j) = 0;
		else
			fprintf('Warm-starting\n');
			adjMatrix = warmStart;
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
		dags{Ind} = ones(p);
		Ind = Ind+1;
		evals(Ind) = evals(Ind-2) + p;
		scores(Ind) = sum(graphScores);
		dags{Ind} = sparse(adjMatrix);
		Ind = Ind+1;

		% Update state indicators
		atLocalMin = 0;
		restart = 0;

	else
		% 1st Iter after Restart

		atLocalMin = 1;

		if restart == 0
			% Test all deletions, additions, reversals

% 			fprintf('Evaluating Deletions\n');
			[delta_graphScores_del delEvals] = EvaluateDeletions(X,adjMatrix,complexityFactor,graphScores,discrete,clamped);
% 			fprintf('Evaluating Additions\n');
			[delta_graphScores_add addEvals] = EvaluateAdditions(X,adjMatrix,complexityFactor,graphScores,discrete,clamped,PP,K);
% 			fprintf('Evaluating Reversals\n');
			[delta_graphScores_revJ delta_graphScores_revI revEvals] = ...
				EvaluateReversals(X,adjMatrix,complexityFactor,...
				graphScores,discrete,clamped,PP,K,delta_graphScores_del);
		else
			% Update the scores of deletions, additions, reversals
			% (based on old scores and changes in graph)

% 			fprintf('Updating Deletions\n');
			[delta_graphScores_del delEvals] = UpdateDeletions(X,adjMatrix,...
				complexityFactor,graphScores,discrete,clamped,delta_graphScores_del,changed);
% 			fprintf('Updating Additions\n');
			[delta_graphScores_add addEvals] = UpdateAdditions(X,adjMatrix,...
				complexityFactor,graphScores,discrete,clamped,PP,K,delta_graphScores_add,changed);
% 			fprintf('Updating Reversals\n');
			[delta_graphScores_revJ delta_graphScores_revI revEvals] = ...
				UpdateReversals(X,adjMatrix,complexityFactor,...
				graphScores,discrete,clamped,PP,K,delta_graphScores_del,...
				delta_graphScores_revJ,delta_graphScores_revI,changed);
		end

		% Find Move that Decreases the Score the most

		[min_del delPos] = min(delta_graphScores_del(:));
		[min_add addPos] = min(delta_graphScores_add(:));
		[min_rev revPos] = min(delta_graphScores_revI(:)+delta_graphScores_revJ(:));

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
			adjMatrix(i,j) = 0;
			changed = j; % delta_graphScores for j's family are obsolete
			graphScores(j) = graphScores(j) + delta_graphScores_del(i,j);
		elseif op == 1
			% Addition
			[i j] = ind2sub(p,addPos);
			adjMatrix(i,j) = 1;
			changed = j; % delta_graphScores for i's family are obsolete
			graphScores(j) = graphScores(j) + delta_graphScores_add(i,j);
		else
			% Reversal
			[i j] = ind2sub(p,revPos);
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
		dags{Ind} = sparse(Lmin_adjMatrix);
		Ind = Ind+1;

		restart = -1;
	end

	if doPlot
		clf;
		subplot(1,2,1);
		myDrawGraph(Lmin_adjMatrix);
		subplot(1,2,2);
		myDrawGraph(Gmin_adjMatrix);
		pause;
	end

	drawnow;
	%fprintf('Saving\n');
	%save(sprintf('results/news%d_iter%d.mat',discrete,iter));

	% Output Iteration Log
	if mod(iter,50)==0
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
	
	if( toc>fixedTime )
		break;
	end

% 	if nargin == 8 && restart == 1
% 		fprintf('Found local minimum, returning\n');
% 		break;
% 	end

end

end

function [familyScore] = EvaluateFamily(X,adjMatrix,complexityFactor,discrete,clamped,i)
% Evaluate pi(i,pa(i))


global allFamilyLogMargLik_trainNeg;

parents = find(adjMatrix(:,i));
index = sum(2.^(parents-1))+1;
familyScore = allFamilyLogMargLik_trainNeg(i,index);

% if discrete
% 	Xsub = [ones(length(X(clamped(:,i)==0,1)),1) X(clamped(:,i)==0,parents)];
% 	ysub = X(clamped(:,i)==0,i);
% 	params = L2LogReg_IRLS(Xsub,ysub);
% 	familyScore = score(LLoss(params,Xsub,ysub),sum(abs(params) >= 1e-4),complexityFactor);
% else
% 	XX = X(clamped(:,i)==0,parents)'*X(clamped(:,i)==0,parents);
% 	Xy = X(clamped(:,i)==0,parents)'*X(clamped(:,i)==0,i);
% 	yy = X(clamped(:,i)==0,i)'*X(clamped(:,i)==0,i);
% 	params = XX\Xy;
% 	familyScore = score(GLoss(XX,Xy,yy,params),sum(adjMatrix(:,i)),complexityFactor);
% end
end

function [graphScores] = EvaluateGraph(X,adjMatrix,complexityFactor,discrete,clamped)
p = length(adjMatrix);
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
		if i ~= j && adjMatrix(i,j) == 0 && adjMatrix(j,i) == 0 %&& PP(i,j) == 1
			adjMatrix_add = adjMatrix;
			adjMatrix_add(i,j) = 1;
			if sum(adjMatrix_add(:,j)) <= K && ~cycles(adjMatrix_add)
				% Evaluate adding i => j
				%fprintf('Evaluating addition of (%d,%d)\n',i,j);
				delta_scores(i,j) = ...
					EvaluateFamily(X,adjMatrix_add,complexityFactor,discrete,clamped,j) ...
					- graphScores(j);
				evals = evals+1;
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
		if i ~= j && adjMatrix(i,j) == 0 && adjMatrix(j,i) == 0 %&& PP(i,j) == 1
			adjMatrix_add = adjMatrix;
			adjMatrix_add(i,j) = 1;
			if sum(adjMatrix_add(:,j)) <= K && ~cycles(adjMatrix_add)
				% Evaluate adding i => j
				%fprintf('Evaluating addition of (%d,%d)\n',i,j);
				if ismember(j,changed) || delta_scores_old(i,j) == 0
					delta_scores(i,j) = ...
						EvaluateFamily(X,adjMatrix_add,complexityFactor,discrete,clamped,j) ...
						- graphScores(j);
					evals = evals+1;
				else
					delta_scores(i,j) = delta_scores_old(i,j);
				end
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
		if adjMatrix(i,j) == 1 %&& PP(j,i) == 1
			adjMatrix_rev = adjMatrix;
			adjMatrix_rev(i,j) = 0;
			adjMatrix_rev(j,i) = 1;
			if sum(adjMatrix_rev(:,i)) <= K && ~cycles(adjMatrix_rev)
				% Evaluate reversing i => j
				%fprintf('Evaluating reversal of (%d,%d)\n',i,j);
				delta_scoresj(i,j) = delta_scores_del(i,j);
				delta_scoresi(i,j) = ...
					EvaluateFamily(X,adjMatrix_rev,complexityFactor,discrete,clamped,i)...
					- graphScores(i);
				evals = evals+1;

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
		if adjMatrix(i,j) == 1 %&& PP(j,i) == 1
			adjMatrix_rev = adjMatrix;
			adjMatrix_rev(i,j) = 0;
			adjMatrix_rev(j,i) = 1;
			if sum(adjMatrix_rev(:,i)) <= K && ~cycles(adjMatrix_rev)
				if ismember(i,changed) || ismember(j,changed) || ...
						(delta_scoresj_old(i,j) == 0 && delta_scoresi_old(i,j) == 0)
					% Evaluate reversing i => j
					%fprintf('Evaluating reversal of (%d,%d)\n',i,j);
					delta_scoresj(i,j) = delta_scores_del(i,j);
					delta_scoresi(i,j) = ...
						EvaluateFamily(X,adjMatrix_rev,complexityFactor,discrete,clamped,i)...
						- graphScores(i);
					evals = evals+1;
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
c = sum(diag((adjMatrix+eye(p))^p) == ones(p,1)) ~= p;
end