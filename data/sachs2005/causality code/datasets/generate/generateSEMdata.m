function [] = generateSEMdata(nNodes,state)
% 10-node: 3,8
% 8-node: 2,3

if nNodes == 10
    nSamples = 4500;
elseif nNodes == 8
    nSamples = 2800;
end
edgeProb = .2; % Probability of putting each edge in SEM
maxIter = 1000; % Number of iterations to run SEMs before taking sample

options.nSamples = nSamples;
options.nNodes = nNodes;
options.edgeProb = edgeProb;
options.maxIter = maxIter;
options.clampSame = 1;
options.strongEdges = 1;

randn('state',state);
rand('state',state);

% Generate a data set with individual nodes clamped
chunkSize = nSamples/nNodes;
clamped = zeros(nSamples,nNodes);
for n = 1:nNodes
    actionNdx = 1+(n-1)*chunkSize:n*chunkSize;
    clamped(actionNdx,n) = 1;
end
options.clamped = clamped;
fprintf('Generating X1\n');
[X1,adj] = sampleSEM(options);
A1 = clamped;

randn('state',state);
rand('state',state);

% Generate a data set with pairs of nodes clamped
chunkSize = nSamples/(nNodes*(nNodes-1)/2);
clamped = zeros(nSamples,nNodes);
chunk = 1;
for n1 = 1:nNodes
    for n2 = n1+1:nNodes
        actionNdx = 1+(chunk-1)*chunkSize:chunk*chunkSize;
        clamped(actionNdx,n1) = 1;
        clamped(actionNdx,n2) = 1;
        chunk = chunk+1;
    end
end
options.clamped = clamped;
fprintf('Generating X2\n');
X2 = sampleSEM(options);
A2 = clamped;

randn('state',state);
rand('state',state);

% Generate a data set with pairs of nodes clamped, and we don't always
% clamp to same action
if nNodes == 10
    nNodes = 20;
    nSamples = 4560;
elseif nNodes == 8
    nNodes = 16;
    nSamples = 2640;
end
options.nSamples = nSamples;
options.nNodes = nNodes;
%options.clampSame = 0;
chunkSize = nSamples/(nNodes*(nNodes-1)/2);
clamped = zeros(nSamples,nNodes);
chunk = 1;
for n1 = 1:nNodes
    for n2 = n1+1:nNodes
        actionNdx = 1+(chunk-1)*chunkSize:chunk*chunkSize;
        clamped(actionNdx,n1) = 1;
        clamped(actionNdx,n2) = 1;
        chunk = chunk+1;
    end
end
options.clamped = clamped;
fprintf('Generating X3\n');
X3 = sampleSEM(options);
X3 = X3(:,1:nNodes/2);
A3 = clamped;

save(sprintf('SEMdata_%d_%d',nNodes/2,state),'X1','A1','X2','A2','X3','A3','adj');
