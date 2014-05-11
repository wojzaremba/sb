function [adj,CPDs] = graphLearn_DN(Y,options)
% [adj] = graphLearn_DN(Y,options)
%
% options:
%   combine: 'directed', 'AND', 'OR'
%
%   likelihood: 'Gaussian', 'Student', 'Probit', 'Logistic', 'Softmax',
%   'Ordinal', 'Ordinal2'
%
%   search: 'fit', 'threshold', 'enumerate', L1', 'greedy'
%
%   select: 'AIC', 'BIC', 'CV', 'L2CV', 'L1CV'
%
%   groupPenalty: 1
%
%   nStates: vector containig number of states for each node (for 'Softmax'
%   and 'Ordinal' only)
%   
%   candidates: nNodes by nNodes matrix that is 0 is n1 is not allowed to
%   be a parent of n2

if nargin < 2
    options = [];
end

[nInstances,nNodes] = size(Y);

[combine,likelihood,search,select,nStates,groupPenalty,clamped,candidates,gibbsIters,CPDoptions] = myProcessOptions(options,'combine','directed',...
    'likelihood','Gaussian','search','enumerate','select','AIC','nStates',[],...
    'groupPenalty',1,'clamped',[],'candidates',[],'gibbsIters',1000,'CPDoptions',[]);

adj = zeros(nNodes);

for n = 1:nNodes
    fprintf('Processing Node %d\n',n);
    
    if isempty(candidates)
        potentialParents = [1:n-1 n+1:nNodes];
    else
        potentialParents = [1:n-1 n+1:nNodes];
        potentialParents(candidates([1:n-1 n+1:nNodes],n)==0) = [];
    end
    nParents = length(potentialParents);
    
    if nParents == 0
        % No allowable parents for this node
        continue;
    end

    switch search
        case 'fit' % Fit parameters, take non-zero coefficients
            [score,model] = graphLearn_fitCPD(Y,n,potentialParents,likelihood,select,nStates,clamped,CPDoptions);
            w = model.getWeights(model);
            parents = potentialParents(find(w ~= 0));
        case 'independent'
            score_noParents = graphLearn_fitCPD(Y,n,[],likelihood,select,nStates,clamped,CPDoptions);
            parents = zeros(0,1);
            for p = 1:length(potentialParents)
               score = graphLearn_fitCPD(Y,n,potentialParents(p),likelihood,select,nStates,clamped,CPDoptions);
               if score < score_noParents
                   parents(end+1) = potentialParents(p);
               end
            end
        case 'threshold' % Fit parameters, then try thresholding parameters to maximize score
            [score,model] = graphLearn_fitCPD(Y,n,potentialParents,likelihood,select,nStates,clamped,CPDoptions);
            w = model.getWeights(model);

            minScore = inf;
            for threshold = sort([abs(w);0])'
                % Threshold values of w

                parentNdx = potentialParents(find(abs(w) > threshold));
                score = graphLearn_fitCPD(Y,n,parentNdx,likelihood,select,nStates,clamped,CPDoptions);

                % Update Min
                if score < minScore
                    minScore = score;
                    minParents = parentNdx;
                end
            end
            parents = minParents;
        case 'L1' % Compute L1 path, then try non-zero subsets along path
            switch likelihood
                case 'Gaussian'
                    w = (lars(Y(:,potentialParents),Y(:,n))'~=0);
                case 'Student'
                    assert(1==0,'L1 Path not currently supported for Student likelihood');
                case 'Probit'
                    w = BinaryL1Path(Y(:,potentialParents),Y(:,n),'Probit');
                case 'Logistic'
                    w = BinaryL1Path(Y(:,potentialParents),Y(:,n),'Logistic');
                case 'Ordinal'
                    w = OrdinalL1Path(Y(:,potentialParents),Y(:,n),nStates(n));
                case 'Softmax'
                    w = SoftmaxL1Path(Y(:,potentialParents),Y(:,n),nStates(potentialParents),nStates(n),groupPenalty);
                case {'Ordinal2','Ordinal3'}
                    w = Ordinal2L1Path(Y(:,potentialParents),Y(:,n),nStates(potentialParents),nStates(n),groupPenalty,likelihood);
            end
            minScore = inf;
            for pathPoint = 1:size(w,2)
                
                if pathPoint ~= 1 && all(w(:,pathPoint)==w(:,pathPoint-1))
                    continue
                end
                
                parentNdx = potentialParents(w(:,pathPoint)~=0);
                score = graphLearn_fitCPD(Y,n,parentNdx,likelihood,select,nStates,clamped,CPDoptions);

                % Update Min
                if score < minScore
                    minScore = score;
                    minParents = parentNdx;
                end
            end
            parents = minParents;
        case 'enumerate' % Search over all combinations of parents
            minScore = inf;
            parents = false(nParents,1);
            while 1

                % Fit Parameters of Gaussian with selected parents
                parentNdx = potentialParents(parents);
                score = graphLearn_fitCPD(Y,n,parentNdx,likelihood,select,nStates,clamped,CPDoptions);

                % Update Min
                if score < minScore
                    minScore = score;
                    minParents = parentNdx;
                end

                % update parents
                for p = 1:nParents
                    if parents(p) == 0
                        parents(p) = 1;
                        break;
                    else
                        parents(p) = 0;
                    end
                end
                if all(parents == 0)
                    break;
                end
            end
            parents = minParents;
        case 'greedy' % Greedy Search
            minScore = inf;
            parents = false(nParents,1);

            % Fit with no parents
            parentNdx = potentialParents(parents);
                score = graphLearn_fitCPD(Y,n,parentNdx,likelihood,select,nStates,clamped,CPDoptions);

            while 1
                % Try all neighbors
                minFlip = 0;
                for p = 1:nParents
                    parents(p) = ~parents(p);
                    parentNdx = potentialParents(parents);
                score = graphLearn_fitCPD(Y,n,parentNdx,likelihood,select,nStates,clamped,CPDoptions);

                    % Update Min
                    if score < minScore
                        minScore = score;
                        minParents = parentNdx;
                        minFlip = p;
                    end

                    parents(p) = ~parents(p);
                end

                if minFlip == 0
                    break;
                else
                    if parents(minFlip)
                       fprintf('Del: %d (node score = %f)\n',minFlip,minScore); 
                    else
                        fprintf('Add: %d (node score = %f)\n',minFlip,minScore);
                    end
                    parents(minFlip) = ~parents(minFlip);
                end
            end
            scores(n,1) = minScore;
        case 'gibbs' % Gibbs-type sampler
            minScore = inf;
            parents = false(nParents,1);
            
            % Fit with no parents
            parentNdx = potentialParents(parents);
            score = graphLearn_fitCPD(Y,n,parentNdx,likelihood,select,nStates,clamped,CPDoptions);
            
            for i = 1:gibbsIters
                p = ceil(rand*nParents);
                parents(p) = ~parents(p);
                parentNdx = potentialParents(parents);
                score_new = graphLearn_fitCPD(Y,n,parentNdx,likelihood,select,nStates,clamped,CPDoptions);

                if score_new < minScore
                    minScore = score_new;
                    minParents = parentNdx;
                end

                potentials = exp(-[score score_new] - mylogsumexp(-[score score_new]));
                change = sampleDiscrete(potentials)-1; % Returns 1 if new state is better

                if ~change
                    % Revert
                    parents(p) = ~parents(p);
                else
                    score = score_new;
                    if parents(p)
                        fprintf('Add: %d (node score = %f, min = %f)\n',p,score_new,minScore);
                    else
                        fprintf('Del: %d (node score = %f, min = %f)\n',p,score_new,minScore);
                    end
                end

            end
            scores(n,1) = minScore;
        otherwise
            error(sprintf('Unrecognized search strategy: %s',search));
    end
    
       fprintf('Parents =  ');
    for p = 1:length(parents)
    fprintf('%d ',parents(p));
    end
    fprintf('\n');
    
    % Update Graph with selected parents
    adj(parents,n) = 1;
end

% Form final result
switch combine
    case 'AND'
        adj = adj.*(adj==adj');
    case 'OR'
        adj = sign(adj+adj');
    otherwise % return partially directed graph
end

if nargout > 1
    fprintf('Computing Final Parameters\n');
    for n = 1:nNodes
        [score,CPDs{n}] = graphLearn_fitCPD(Y,n,find(adj(:,n)),likelihood,select,nStates,clamped,CPDoptions);
    end
end

end

%%
function [wPath] = SoftmaxL1Path(X,y,nStatesX,nStates,groupPenalty)
[n,p] = size(X);

% Make groups
groups = zeros(sum(nStatesX),1);
offset = 1;
for v = 1:p
    groups(offset:offset+nStatesX(v)-1) = v;
    offset = offset+nStatesX(v);
end
groups = [0;groups];
nGroups = max(groups);

% Make new X
Xnew = -ones(n,sum(nStatesX));
for i = 1:n
    offset = 1;
    for v = 1:p
        Xnew(i,offset+X(i,v)-1) = 1;
        offset = offset+nStatesX(v);
    end
end
Xnew = [ones(n,1) Xnew];
nVars = size(Xnew,2);

funObj_bias = @(w)SoftmaxLoss(w,Xnew(:,1),y,nStates);
w = zeros(nVars,nStates);
w(1,:) = minFunc(funObj_bias,zeros(nStates,1),struct('Display','none'));
w = w(:);

funObj = @(w)SoftmaxLoss(w,Xnew,y,nStates);
[f,g] = funObj(w);
options.verbose = 0;
wPath = zeros(p,1);
switch groupPenalty
    case 1
        maxLambda = max(abs(g(:)));
        increment = maxLambda/(p+2);
        wPath = zeros(p,1);
        for lambda = maxLambda-increment:-increment:increment
            lambdaMatrix = lambda*ones(nVars,nStates);
            lambdaMatrix(1,:) = 0;
            w = L1GeneralProjectedSubGradient(funObj,w,lambdaMatrix(:),options);

            w2 = reshape(w,nVars,nStates);
            wPath(:,end+1) = accumarray(groups(2:end),sum(abs(w2(2:end,:)),2))~=0;
        end
    otherwise
        groups2 = repmat(groups,[1 nStates]);
        groups2 = groups2(:);
        maxLambda = 0;
        for group = 1:nGroups
            if groupPenalty == 2
                ng = norm(g(groups2==group),2);
            elseif groupPenalty == inf
                ng = norm(g(groups2==group),1);
            else
                error('Unrecognized groupPenalty');
            end

            if ng > maxLambda
                maxLambda = ng;
            end
        end
        increment = maxLambda/(p+2);
        for lambda = maxLambda-increment:-increment:increment
            loss = @(w)auxGroupLoss(w,groups2,lambda,funObj);
            if groupPenalty == 2
            funProj = @(w)auxGroupL2Proj(w,groups2);
            else
            funProj = @(w)auxGroupLinfProj(w,groups2);
            end
            wAlpha = minConF_SPG(loss,[w;zeros(nGroups,1)],funProj,options);
            
            w2 = reshape(wAlpha(1:numel(w)),nVars,nStates);
            wPath(:,end+1) = accumarray(groups(2:end),sum(abs(w2(2:end,:)),2))~=0;
        end
end
wPath(:,end+1) = ones(p,1);
end

%%
function [wPath] = Ordinal2L1Path(X,y,nStatesX,nStates,groupPenalty,likelihood)
[n,p] = size(X);

% Make groups
groups = zeros(sum(nStatesX),1);
offset = 1;
for v = 1:p
    groups(offset:offset+nStatesX(v)-1) = v;
    offset = offset+nStatesX(v);
end
groups = [0;groups];
nGroups = max(groups);

% Make new X
Xnew = -ones(n,sum(nStatesX));
for i = 1:n
    offset = 1;
    for v = 1:p
        if strcmp(likelihood,'Ordinal2')
            Xnew(i,offset+X(i,v)-1) = 1;
        else
            Xnew(i,offset:offset+X(i,v)-1) = 1;
        end
        offset = offset+nStatesX(v);
    end
end
Xnew = [ones(n,1) Xnew];
nVars = size(Xnew,2);

funObj_bias = @(w)OrdinalLogisticLoss2(w,Xnew(:,1),y,nStates);
LB = [-inf;zeros(nStates-2,1)];
UB = inf(nStates-1,1);
w = [zeros(nVars,1);ones(nStates-2,1)];
options.order = 1;
options.verbose = 0;
w([1 nVars+1:end],:) = minConF_TMP(funObj_bias,w([1 nVars+1:end],:),LB,UB,options);

funObj = @(w)OrdinalLogisticLoss2(w,Xnew,y,nStates);
LB = [-inf(nVars,1);ones(nStates-2,1)];
UB = inf(nVars+nStates-2,1);
[f,g] = funObj(w);
wPath = zeros(p,1);
assert(groupPenalty == 1,'Only groupPenalty==1 implemented for Ordinal');
        maxLambda = max(abs(g(:)));
        increment = maxLambda/(p+2);
        wPath = zeros(p,1);
        for lambda = maxLambda-increment:-increment:increment
            lambdaVect = lambda*[0;ones(nVars-1,1);zeros(nStates-2,1)];
            w = BoundConstrainedL1GeneralPSG(funObj,w,lambdaVect,LB,UB,options);
            wPath(:,end+1) = accumarray(groups(2:end),abs(w(2:nVars)))~=0;
        end
wPath(:,end+1) = ones(p,1);
end

%%
function [wPath] = OrdinalL1Path(X,y,nStates)
[n,p] = size(X);
X = [ones(n,1) X];
options.verbose = 0;

% Compute bias and thresholds with no parents
funObj_bias = @(w)OrdinalLogisticLoss2(w,X(:,1),y,nStates);
LB = [-inf(1,1);zeros(nStates-2,1)];
UB = inf(1+nStates-2,1);
biasThresh = minConF_TMP(funObj_bias,[0;ones(nStates-2,1)],LB,UB,options);

% Compute maxLambda
w = [biasThresh(1);zeros(p,1);biasThresh(2:end)];
funObj = @(w)OrdinalLogisticLoss2(w,X,y,nStates);
[f,g] = funObj(w);
maxLambda = max(abs(g));
increment = maxLambda/(p+2);
LB = [-inf(p+1,1);zeros(nStates-2,1)];
UB = inf(p+1+nStates-2,1);
options.order = 1;
wPath = zeros(p,1);
for lambda = maxLambda-increment:-increment:increment
    lambdaVect = [0;lambda*ones(p,1);zeros(nStates-2,1)];
    w=BoundConstrainedL1GeneralPSG(funObj,w,lambdaVect,LB,UB,options);
    wPath(:,end+1) = w(2:p+1)~=0;
end
wPath(:,end+1) = ones(p,1);
end

%%
function [w] = BinaryL1Path(X,y,type)
[n,p] = size(X);
X = [ones(n,1) X];
switch type
    case 'Probit'
        funObj_bias = @(w)ProbitLoss(w,X(:,1),y);
    case 'Logistic'
        funObj_bias = @(w)LogisticLoss(w,X(:,1),y);
end
w = zeros(p+1,1);
w(1) = minFunc(funObj_bias,0,struct('Display','none'));
switch type
    case 'Probit'
        funObj = @(w)ProbitLoss(w,X,y);
    case 'Logistic'
        funObj = @(w)LogisticLoss(w,X,y);
end
[f,g] = funObj(w);
maxLambda = max(abs(g));
increment = maxLambda/(p+2);
options.verbose = 0;
for lambda = maxLambda-increment:-increment:increment
    w(:,end+1) = L1GeneralProjectedSubGradient(funObj,w(:,end),[0;max(lambda,0)*ones(p,1)],options);
end
w(:,end+1) = ones(p+1,1);
w = w(2:end,:)~=0;
end



