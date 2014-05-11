function [X,adj] = sampleSEM(options)

draw = 0;

[nSamples,nNodes,edgeProb,maxIter,clamped,clampSame,strongEdges] = myProcessOptions(options,...
    'nSamples',100,'nNodes',8,'edgeProb',.25,'maxIter',1000,...
    'clamped',[],'clampSame',1,'strongEdges',1);

% Generate Parameters of Model
if strongEdges
    bias = randn(nNodes,1);
    adj = rand(nNodes) < edgeProb;
    weights = (randn(nNodes)+5*sign(randn(nNodes))).*adj;
else
    bias = randn(nNodes,1);
    weights = randn(nNodes).*(rand(nNodes) < edgeProb);
end
weights = setdiag(weights,0);

if draw
    % Draw Graph
    figure(1);clf;drawGraph(weights~=0)
end

% Find parents
for n = 1:nNodes
    parents{n} = find(weights(:,n)~=0);
end

% Generate Initial States based on noise alone
X = zeros(nSamples,nNodes);
for s = 1:nSamples
    for n = 1:nNodes
        p = 1/(1 + exp(-bias(n)));
        if rand < p
            X(s,n) = 1;
        else
            X(s,n) = -1;
        end
    end
end

% Set values of nodes clamped by intervention
clampedValues = sign(randn(nNodes,1));
if isempty(clamped)
    clamped = zeros(nSamples,nNodes);
else
    for s = 1:nSamples
        for n = 1:nNodes
            if clamped(s,n)
                if clampSame
                    X(s,n) = clampedValues(n); % Clamp it to this action's value
                else
                    X(s,n) = sign(randn); % Clamp it to a random state
                end
            end
        end
    end
end

if draw
    figure(2);
    imagesc(X);
    title('Initialization');
end

% Now Update Nodes whose parents have changed
changed = ones(nSamples,nNodes);
for i = 1:maxIter
    if mod(i,50)==0
        fprintf('Sampling iteration %d of %d\n',i,maxIter);
    end
    
    X_old = X;
    changed_old = changed;
    for s = 1:nSamples
        for n = 1:nNodes
            if ~clamped(s,n) && any(changed_old(s,parents{n}))
                p = 1/(1 + exp(-bias(n) - X_old(s,parents{n})*weights(parents{n},n)));
                if rand < p
                    X(s,n) = 1;
                else
                    X(s,n) = -1;
                end
                changed(s,n) = 1;
            else
                changed(s,n) = 0;
            end
        end
    end
end
if draw
    figure(3);
    imagesc(X);
    title('Samples from model');
    pause
end
