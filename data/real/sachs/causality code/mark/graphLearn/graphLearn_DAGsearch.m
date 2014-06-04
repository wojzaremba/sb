function [adj,model] = graphLearn_DAG(Y,options)
% [adj] = graphLearn_DN(Y,options)
%
% options common with graphLearn_DN:
%   likelihood, select, groupPenalty, nStates
%
% other options:
%   adj: initial adjacency matrix

DEBUG = 0; % Turns on extra checks to make sure everything is working properly (SLOWER!)

if nargin < 2
    options = [];
end

[nInstances,nNodes] = size(Y);

[adj,likelihood,select,nStates,groupPenalty,clamped,candidates,alwaysDelete,gradientPruning,CPDoptions] = ...
    myProcessOptions(options,...
    'adj',zeros(nNodes),'likelihood','Gaussian','select','BIC','nStates',[],'groupPenalty',1,...
    'clamped',[],'candidates',ones(nNodes),'alwaysDelete',0,'gradientPruning',0,'CPDoptions',[]);

%% Initialization

% Build initial ancestor matrix
anc = ancestorMatrixBuildC(adj);

% Compute score of initial graph
fprintf('Evaluating initial graphs\n');
for n = 1:nNodes
    score(n) = graphLearn_fitCPD(Y,n,find(adj(:,n)),likelihood,select,nStates,clamped,CPDoptions);
end

scores_add = inf(nNodes);
if gradientPruning
    % Compute Magnitudes of Gradient for non-parents
    % (currently only implemented for the Gaussian case)
    gMag = zeros(nNodes);
    for c = 1:nNodes
        gMag(:,c) = gradMag(Y,c,adj,clamped,candidates);
        maxInd(c) = getMaxInd(gMag,c,anc);
    end

    % Evaluate addition with biggest gradient magnitude
    fprintf('Evaluating locally best additions\n');
    for c = 1:nNodes
        p = maxInd(c);
        if p ~= 0
            scores_add(p,c) = graphLearn_fitCPD(Y,c,[p;find(adj(:,c))],likelihood,select,nStates,clamped,CPDoptions)-score(c);
        end
    end

else
    % Evaluate additions that don't make cycles
    fprintf('Evaluating all additions\n');
    for c = 1:nNodes
        for p = 1:nNodes
            if c ~= p && adj(p,c) == 0 && anc(c,p) == 0 && candidates(p,c) == 1
                scores_add(p,c) = graphLearn_fitCPD(Y,c,[p;find(adj(:,c))],likelihood,select,nStates,clamped,CPDoptions)-score(c);
            end
        end
    end
end

% Evaluate deletions
fprintf('Evaluating all deletions\n');
scores_delete = inf(nNodes);
for c = 1:nNodes
    for p = 1:nNodes
        if adj(p,c) == 1
            scores_delete(p,c) = graphLearn_fitCPD(Y,c,setdiff(find(adj(:,c)),p),likelihood,select,nStates,clamped,CPDoptions)-score(c);
        end
    end
end

% Evaluate reversals that don't make cycles
fprintf('Evaluating all reversals\n');
scores_reversal = inf(nNodes);
for c = 1:nNodes
    for p = 1:nNodes
        if adj(p,c) == 1 && candidates(c,p) == 1 && ~any(anc(p,find(anc(:,c)))==1)
            % Score change of adding c->p
            % (net change is adds change after deletion of p->c)
            scores_reversal(p,c) = graphLearn_fitCPD(Y,p,[c;find(adj(:,p))],likelihood,select,nStates,clamped,CPDoptions) - score(p);
        end
    end
end

%% Main Loop

while 1
    fprintf('Score = %.2f, ',sum(score));
    % If no move can improve the score, stop
    if alwaysDelete
        bestMoves = [0 min(scores_delete(:)) 0];
        [bestMoveScore bestMoveInd] = min(bestMoves);
        if bestMoveScore >= 0
            bestMoves = [min(scores_add(:)) min(scores_delete(:)) min(scores_reversal(:)+scores_delete(:))];
            [bestMoveScore bestMoveInd] = min(bestMoves);
        end
    else
        bestMoves = [min(scores_add(:)) min(scores_delete(:)) min(scores_reversal(:)+scores_delete(:))];
        [bestMoveScore bestMoveInd] = min(bestMoves);
    end
    if bestMoveScore >= 0
        fprintf('Local Minimum Found\n');
        break
    end

    switch bestMoveInd
        case 1
            [i j] = find(scores_add==bestMoves(1));
            i = i(1);
            j = j(1);
            fprintf('Adding Edge from %d to %d\n',i,j);

            % Update score, adjacency matrix, and ancestor matrix
            score_old = score(j);
            score(j) = scores_add(i,j) + score(j);
            adj(i,j) = 1;
            ancestorMatrixAddC_InPlace(anc,i,j);

            if gradientPruning
                gMag(:,j) = gradMag(Y,j,adj,clamped,candidates);

                % Update scores of additions
                for c = 1:nNodes
                    maxOld = maxInd(c);
                    maxInd(c) = getMaxInd(gMag,c,anc);
                    if maxOld ~= maxInd(c)
                        scores_add(:,c) = inf;
                        p = maxInd(c);
                        if p ~= 0
                            scores_add(p,c) = graphLearn_fitCPD(Y,c,[p;find(adj(:,c))],likelihood,select,nStates,clamped,CPDoptions)-score(c);
                        end
                    end
                end
            else
                % Update scores of adding edges into j
                c = j;
                scores_add(:,c) = inf;
                for p = 1:nNodes
                    if c ~= p && adj(p,c) == 0 && anc(c,p) == 0 && candidates(p,c) == 1
                        scores_add(p,c) = graphLearn_fitCPD(Y,c,[p;find(adj(:,c))],likelihood,select,nStates,clamped,CPDoptions)-score(c);
                    end
                end

                % Set score to inf for additions that will now cause a cycle
                ancT = anc';
                scores_add(ancT(:)==1) = inf;
            end

            % Update scores of deleting edges into j
            c = j;
            scores_delete(:,c) = inf;
            for p = 1:nNodes
                if p == i
                    scores_delete(p,c) = score_old-score(c); % Deleting edge just added
                elseif adj(p,c) == 1
                    scores_delete(p,c) = graphLearn_fitCPD(Y,c,setdiff(find(adj(:,c)),p),likelihood,select,nStates,clamped,CPDoptions)-score(c);
                end
            end

            % Compute score of reversing new edge if it does not cause a cycle
            p = i;
            c = j;
            if candidates(c,p) == 1 && ~any(anc(p,find(anc(:,c)))==1)
                scores_reversal(i,j) = graphLearn_fitCPD(Y,p,[c;find(adj(:,p))],likelihood,select,nStates,clamped,CPDoptions) - score(p);
            end

            % Update scores of reversing edges leaving j
            p = j;
            scores_reversal(p,:) = inf;
            for c = 1:nNodes
                if adj(p,c) == 1 && candidates(c,p)==1 && ~any(anc(p,find(anc(:,c)))==1)
                    % Score change of deleting p->c and adding c->p
                    %fprintf('Evaluating Reversal leaving j!\n');
                    scores_reversal(p,c) = graphLearn_fitCPD(Y,p,[c;find(adj(:,p))],likelihood,select,nStates,clamped,CPDoptions) - score(p);
                end
            end

            % Set score to inf for reversals that will now cause a cycle
            for p = 1:nNodes
                for c = 1:nNodes
                    if adj(p,c) == 1 && ~isinf(scores_reversal(p,c)) && any(anc(p,find(anc(:,c)))==1)
                        %fprintf('Setting score to inf of a reversal that will now cause a cycle\n');
                        scores_reversal(p,c) = inf;
                    end
                end
            end

        case 2
            [i j] = find(scores_delete==bestMoves(2));
            i = i(1);
            j = j(1);
            fprintf('Deleting Edge from %d to %d\n',i,j);

            % Update score, adjacency matrix, and ancestor matrix
            score_old = score(j);
            score(j) = scores_delete(i,j) + score(j);
            adj(i,j) = 0;
            anc = ancestorMatrixBuildC(adj);

            if gradientPruning
                gMag(:,j) = gradMag(Y,j,adj,clamped,candidates);

                % Update scores of additions
                for c = 1:nNodes
                    maxOld = maxInd(c);
                    maxInd(c) = getMaxInd(gMag,c,anc);
                    if maxOld ~= maxInd(c)
                        scores_add(:,c) = inf;
                        p = maxInd(c);
                        if p ~= 0
                            scores_add(p,c) = graphLearn_fitCPD(Y,c,[p;find(adj(:,c))],likelihood,select,nStates,clamped,CPDoptions)-score(c);
                        end
                    end
                end
            else

                % Update scores of adding edges into j
                c = j;
                scores_add(:,c) = inf;
                for p = 1:nNodes
                    if c ~= p && adj(p,c) == 0 && anc(c,p) == 0 && candidates(p,c) == 1
                        if p == i
                            scores_add(p,c) = score_old - score(j);
                        else
                            scores_add(p,c) = graphLearn_fitCPD(Y,c,[p;find(adj(:,c))],likelihood,select,nStates,clamped,CPDoptions)-score(c);
                        end
                    end
                end

                % Compute scores for additions that will no longer cause a
                % cycle
                for c = 1:nNodes
                    for p = 1:nNodes
                        if c ~= p && adj(p,c) == 0 && anc(c,p) == 0 && isinf(scores_add(p,c)) && candidates(p,c) == 1
                            %fprintf('Computing Score for Addition that no longer causes a cycle!\n');
                            scores_add(p,c) = graphLearn_fitCPD(Y,c,[p;find(adj(:,c))],likelihood,select,nStates,clamped,CPDoptions)-score(c);
                        end
                    end
                end
            end

            % Update scores of removing more edge into j
            c = j;
            scores_delete(:,c) = inf;
            for p = 1:nNodes
                if adj(p,c) == 1
                    scores_delete(p,c) = graphLearn_fitCPD(Y,c,setdiff(find(adj(:,c)),p),likelihood,select,nStates,clamped,CPDoptions)-score(c);
                end
            end

            % Update score of reversing edge just deleted
            scores_reversal(i,j) = inf;

            % Update scores of reversing edges out of j
            p = j;
            scores_reversal(p,:) = inf;
            for c = 1:nNodes
                if adj(p,c) == 1 && candidates(c,p)==1 && ~any(anc(p,find(anc(:,c)))==1)
                    scores_reversal(p,c) = graphLearn_fitCPD(Y,p,[c;find(adj(:,p))],likelihood,select,nStates,clamped,CPDoptions) - score(p);
                end
            end

            % Compute scores for reversals that will no longer cause a
            % cycle
            for c = 1:nNodes
                for p = 1:nNodes
                    if adj(p,c) == 1 && isinf(scores_reversal(p,c)) && candidates(c,p) == 1 && ~any(anc(p,find(anc(:,c)))==1)
                        % Score change of adding c->p
                        % (net change is adds change after deletion of
                        % p->c)
                        %fprintf('Computing Score for Reversal that no longer causes a cycle!\n');
                        scores_reversal(p,c) = graphLearn_fitCPD(Y,p,[c;find(adj(:,p))],likelihood,select,nStates,clamped,CPDoptions) - score(p);
                    end
                end
            end

        case 3
            [i j] = find(scores_reversal+scores_delete==bestMoves(3));
            i = i(1);
            j = j(1);
            fprintf('Reversing Edge from %d to %d\n',i,j);

            % Update score, adjacency matrix, and ancestor matrix
            score_old_j = score(j);
            score_old_i = score(i);
            score(i) = scores_reversal(i,j) + score(i);
            score(j) = scores_delete(i,j) + score(j);
            adj(i,j) = 0;
            adj(j,i) = 1;
            anc = ancestorMatrixBuildC(adj);

            if gradientPruning
                gMag(:,i) = gradMag(Y,i,adj,clamped,candidates);
                gMag(:,j) = gradMag(Y,j,adj,clamped,candidates);

                % Update scores of additions
                for c = 1:nNodes
                    maxOld = maxInd(c);
                    maxInd(c) = getMaxInd(gMag,c,anc);
                    if maxOld ~= maxInd(c)
                        scores_add(:,c) = inf;
                        p = maxInd(c);
                        if p ~= 0
                            scores_add(p,c) = graphLearn_fitCPD(Y,c,[p;find(adj(:,c))],likelihood,select,nStates,clamped,CPDoptions)-score(c);
                        end
                    end
                end
            else
                % Update scores of adding edges into i
                c = i;
                scores_add(:,c) = inf;
                for p = 1:nNodes
                    if c ~= p && adj(p,c) == 0 && anc(c,p) == 0 && candidates(p,c) == 1
                        scores_add(p,c) = graphLearn_fitCPD(Y,c,[p;find(adj(:,c))],likelihood,select,nStates,clamped,CPDoptions)-score(c);
                    end
                end

                % Update scores of adding edges into j
                c = j;
                scores_add(:,c) = inf;
                for p = 1:nNodes
                    if c ~= p && adj(p,c) == 0 && anc(c,p) == 0 && candidates(p,c) == 1
                        scores_add(p,c) = graphLearn_fitCPD(Y,c,[p;find(adj(:,c))],likelihood,select,nStates,clamped,CPDoptions)-score(c);
                    end
                end

                % Compute scores for additions that will no longer cause a
                % cycle, and set scores to inf for additions that will now
                % cause a cycle
                for c = 1:nNodes
                    for p = 1:nNodes
                        if c ~= p && adj(p,c) == 0 && anc(c,p) == 0 && candidates(p,c) == 1
                            if isinf(scores_add(p,c))
                                %fprintf('Computing Score for Addition that no longer causes a cycle!\n');
                                scores_add(p,c) = graphLearn_fitCPD(Y,c,[p;find(adj(:,c))],likelihood,select,nStates,clamped,CPDoptions)-score(c);
                            end
                        else
                            scores_add(p,c) = inf;
                        end
                    end
                end
            end

            % Update scores of deleting edges into i
            c = i;
            scores_delete(:,c) = inf;
            for p = 1:nNodes
                if adj(p,c) == 1
                    scores_delete(p,c) = graphLearn_fitCPD(Y,c,setdiff(find(adj(:,c)),p),likelihood,select,nStates,clamped,CPDoptions)-score(c);
                end
            end

            % Update scores of deleting edges into j
            c = j;
            scores_delete(:,c) = inf;
            for p = 1:nNodes
                if adj(p,c) == 1
                    scores_delete(p,c) = graphLearn_fitCPD(Y,c,setdiff(find(adj(:,c)),p),likelihood,select,nStates,clamped,CPDoptions)-score(c);
                end
            end

            % Update scores of reversing edges out of i
            p = i;
            scores_reversal(p,:) = inf;
            for c = 1:nNodes
                if adj(p,c) == 1 && candidates(c,p) == 1 && ~any(anc(p,find(anc(:,c)))==1)
                    % Score change of deleting p->c and adding c->p
                    scores_reversal(p,c) = graphLearn_fitCPD(Y,p,[c;find(adj(:,p))],likelihood,select,nStates,clamped,CPDoptions) - score(p);
                end
            end

            % Update scores of reversing edges out of j
            p = j;
            scores_reversal(p,:) = inf;
            for c = 1:nNodes
                if adj(p,c) == 1 && candidates(c,p) == 1 && ~any(anc(p,find(anc(:,c)))==1)
                    % Score change of deleting p->c and adding c->p
                    if c == i
                        % This is the edge we just reversed
                        scores_reversal(p,c) = score_old_j - score(p);
                    else
                        scores_reversal(p,c) = graphLearn_fitCPD(Y,p,[c;find(adj(:,p))],likelihood,select,nStates,clamped,CPDoptions) - score(p);
                    end
                end
            end


            % Compute scores for reversals that will no longer cause a
            % cycle, and set score to inf for reversals that will now cause
            % a cycle
            for c = 1:nNodes
                for p = 1:nNodes
                    if adj(p,c) == 1 && candidates(c,p) == 1 && ~any(anc(p,find(anc(:,c)))==1)
                        % Score change of adding c->p
                        % (net change is adds change after deletion of p->c)
                        if isinf(scores_reversal(p,c))
                            %fprintf('Computing Score for Reversal that no longer causes a cycle!\n');
                            scores_reversal(p,c) = graphLearn_fitCPD(Y,p,[c;find(adj(:,p))],likelihood,select,nStates,clamped,CPDoptions) - score(p);
                        end
                    else
                        scores_reversal(p,c) = inf;
                    end
                end
            end

    end

    if DEBUG
        assert(~cycles(adj),'Adjacency Matrix has cycles!'); % Check that graph is acyclic
        assert(all(anc == ancestorMatrixBuildC(adj)),'Ancestor Matrix is wrong!'); % Check that ancestor matrix is right
        for n = 1:nNodes
            % Check that score is right
            assert(1e-10 > abs(score(n)-graphLearn_fitCPD(Y,n,find(adj(:,n)),likelihood,select,nStates,clamped,CPDoptions)),'Running score is wrong!');
        end

        % Check that addition score changes are right
        for p = 1:nNodes
            for c = 1:nNodes
                if c ~= p && adj(p,c) == 0 && anc(c,p) == 0 && candidates(p,c) == 1
                    assert(1e-10 > abs(-scores_add(p,c) + graphLearn_fitCPD(Y,c,[p;find(adj(:,c))],likelihood,select,nStates,clamped,CPDoptions)-score(c)),'Score update for addition is wrong!');
                else
                    assert(scores_add(p,c)==inf,'Score update for addition is wrong!');
                end
            end
        end

        % Check that deletion score changes are right
        for c = 1:nNodes
            for p = 1:nNodes
                if adj(p,c) == 1
                    if 1e-10 < abs(-scores_delete(p,c) + graphLearn_fitCPD(Y,c,setdiff(find(adj(:,c)),p),likelihood,select,nStates,clamped,CPDoptions)-score(c))
                        error('Score update for deletion is wrong!\n');
                    end
                else
                    assert(scores_delete(p,c)==inf,'Score update for deletion is wrong!\n');
                end
            end
        end

        % Check that reversal scores change are right
        for c = 1:nNodes
            for p = 1:nNodes
                if adj(p,c) == 1 && candidates(c,p) == 1 && ~any(anc(p,find(anc(:,c)))==1)
                    assert(1e-10 > abs(-scores_reversal(p,c) + graphLearn_fitCPD(Y,p,[c;find(adj(:,p))],likelihood,select,nStates,clamped,CPDoptions) - score(p)),'Score udpate for reversal is wrong!\n');
                else
                    if scores_reversal(p,c)~=inf
                        error('Score udpate for reversal is wrong!\n');
                    end
                end
            end
        end
    end
end

if nargout > 1
    fprintf('Computing Final Parameters\n');
    for n = 1:nNodes
        [score,model{n}] = graphLearn_fitCPD(Y,n,find(adj(:,n)),likelihood,select,nStates,clamped,CPDoptions);
    end
end
end

% Returns 1 if the graph has cycles (slower than using ancestor matrix)
function [c] = cycles(adjMatrix)
p = length(adjMatrix);
c = sum(diag((sparse(adjMatrix+eye(p)))^p) == ones(p,1)) ~= p;
end


function [g] = gradMag(Y,c,adj,clamped,candidates)
% Compute magnitude of gradient of potential parents
% (ignoring acyclicity)

Y = Y(clamped(:,c)==0,:);

[nInstances,nNodes] = size(Y);

g = -inf(nNodes,1);

parents = find(adj(:,c));
nParents = length(parents);
if nParents == 0
    for p = 1:nNodes
        if c ~= p && adj(p,c) == 0 && candidates(p,c) == 1
            g(p) = abs(Y(:,p)'*Y(:,c));
        end
    end
else
    % Compute params
    w = Y(:,parents)\Y(:,c);
    for p = 1:nNodes
       if c ~= p && adj(p,c) == 0 && candidates(p,c) == 1
          g(p) = abs(Y(:,p)'*(Y(:,[p;parents])*[0;w]) - Y(:,p)'*Y(:,c));
       end
    end
end
end

function [maxInd] = getMaxInd(g,c,anc)
    g = g(:,c);
    g(anc(c,:)==1) = -inf;
    [maxVal maxInd] = max(g);
    if isinf(maxVal)
        maxInd = 0;
    end
end