function model = factorGraph_exp_DAG(Y,lambdaL2)

[nSamples,nNodes] = size(Y);
nStates = max(Y(:));

% Train
options.likelihood = 'Softmax';
options.nStates = repmat(nStates,nNodes,1);

options.select = 'RegObj';
options.search = 'fit';
CPDoptions.lambdaL2 = lambdaL2;
options.CPDoptions = CPDoptions;
options.candidates = triu(ones(nNodes),1);
[adj,CPDs] = graphLearn_DN(Y,options);

model.adj = adj;
model.CPDs = CPDs;
model.nStates = nStates;
model.nll = @nll;
model.nll_unnormalized = @nll;

end

function NLL = nll(model,Y)
[nSamples,nNodes] = size(Y);

nStates = model.nStates;
adj = model.adj;
CPDs = model.CPDs;

NLL = zeros(nSamples,1);
for n = 1:nNodes
    parents = find(adj(:,n));
    X = Y(:,parents);
    nParents = size(X,2);
    Xnew = zeros(nSamples,nStates*nParents);
    for i = 1:nSamples
        offset = 1;
        for v = 1:nParents
            Xnew(i,offset+X(i,v)-1) = 1;
            offset = offset+nStates;
        end
    end
    X = [ones(nSamples,1) Xnew];
    NLL = NLL - CPDs{n}.loglik2(CPDs{n},X,Y(:,n));
end
end
