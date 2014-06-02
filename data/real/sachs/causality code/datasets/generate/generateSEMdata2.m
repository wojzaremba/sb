function [] = generateSEMdata2(state)
% 8-node: seed = 2,3

randn('state',state);
rand('state',state);

nNodes = 16;
nSamples = 5600;
edgeProb = .2; % Probability of putting each edge in SEM
maxIter = 1000; % Number of iterations to run SEMs before taking sample

options.nSamples = nSamples;
options.nNodes = nNodes;
options.edgeProb = edgeProb;
options.maxIter = maxIter;
options.clampSame = 1;
options.strongEdges = 1;

% Generate a data set with pairs of nodes clamped, and we don't always
% clamp to same action

chunkSize = nSamples/(8*(8-1)/2);
clamped = zeros(nSamples,nNodes);
chunk = 1;
for n1 = 1:8
    for n2 = n1+1:8
        actionNdx = 1+(chunk-1)*chunkSize:chunk*chunkSize;
        clamped(actionNdx,n1) = 1;
        clamped(actionNdx,n2) = 1;
        chunk = chunk+1;
    end
end
options.clamped = clamped;
fprintf('Generating X3\n');
X = sampleSEM(options);
X = X(:,1:2:nNodes);
A = clamped(:,1:nNodes/2);

save(sprintf('SEMdata_8_%d_hidden.mat',state),'X','A');
