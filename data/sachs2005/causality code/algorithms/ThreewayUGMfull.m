function model = factorGraph_exp_PairwiseUGMfull(Y,lambda)

[nInstances,nNodes] = size(Y);
nStates = max(Y(:));

% Use all possible edges
e = 1;
for i = 1:nNodes
    for j = i+1:nNodes
        edges2(e,:) = [i j];
        e = e + 1;
    end
end

e = 1;
for i = 1:nNodes
    for j = i+1:nNodes
        for k = j+1:nNodes
            edges3(e,:) = [i j k];
            e = e + 1;
        end
    end
end

nEdges2 = size(edges2,1);
nEdges3 = size(edges3,1);
w1 = zeros(nStates,nNodes);
w2 = zeros(nStates,nStates,nEdges2);
w3 = zeros(nStates,nStates,nStates,nEdges3);

[ind1,ind2,ind3] = factorGraph_makeIndices3(nStates,nNodes,nEdges2,nEdges3);
funObj = @(w)factorGraph_nll3(w,ind1,ind2,ind3,Y,nStates,edges2,edges3);


w = [w1(ind1);w2(ind2);w3(ind3)];

fprintf('Lambda = %f\n',lambda);
regVect = lambda*[zeros(size(w1(ind1)));ones(size(w2(ind2)));ones(size(w3(ind3)))];
options.maxFunEvals = 500;
options.Display = 'Full';
options.TolX = 1e-5;
options.TolFun = 1e-5;
w = minFunc(@penalizedL2,w,options,funObj,regVect);

model.w = w;
model.nStates = nStates;
model.edges2 = edges2;
model.edges3 = edges3;
model.nll = @nll;
model.nll_unnormalized = @nll_unnormalized;
end


function NLL = nll(model,Y)

[nInstances,nNodes] = size(Y);

w = model.w;
nStates = model.nStates;
edges2 = model.edges2;
edges3 = model.edges3;

nEdges2 = size(edges2,1);
nEdges3 = size(edges3,1);
[ind1,ind2,ind3] = factorGraph_makeIndices3(nStates,nNodes,nEdges2,nEdges3);

    NLL = factorGraph_nll3b(w,ind1,ind2,ind3,Y,nStates,edges2,edges3);
end

function NLL = nll_unnormalized(model,Y)

[nInstances,nNodes] = size(Y);

w = model.w;
nStates = model.nStates;
edges2 = model.edges2;
edges3 = model.edges3;

nEdges2 = size(edges2,1);
nEdges3 = size(edges3,1);
[ind1,ind2,ind3] = factorGraph_makeIndices3(nStates,nNodes,nEdges2,nEdges3);

    NLL = factorGraph_nll3c(w,ind1,ind2,ind3,Y,nStates,edges2,edges3);
end
