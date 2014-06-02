function model = bernoulli_ind(data,dirPrior)
% fits a seperate product of bernoullis for every action regime

X = data.X;
[nInst,nNodes] = size(X);
nStates = data.nStates;

% Sort actions
A = data.A;
[A,ind] = sortrows(A);
X = X(ind,:);

% Train
mu = zeros(nNodes,nStates,1);
action = 1;
for i = 1:nInst
    for n = 1:nNodes
       mu(n,X(i,n),action) = mu(n,X(i,n),action)+1; 
    end
    
    if i < nInst && ~all(A(i,:)==A(i+1,:))
        action = action+1;
        mu(:,:,action) = zeros(nNodes,nStates);
    end
end
mu = mu+dirPrior;
nActions = action;

% Normalize
for n = 1:nNodes
    for a = 1:nActions
        mu(n,:,a) = mu(n,:,a)/sum(mu(n,:,a));
    end
end

model.mu = mu;
model.actions = unique(A,'rows');
model.nll = @nll;
model.nll_unnormalized = @nll;

end

function NLL = nll(model,data)

X = data.X;
A = data.A;
nStates = data.nStates;

mu = model.mu;
actions = model.actions;

[nInst,nNodes] = size(X);
nActions = size(mu,3);

NLL = zeros(nInst,1);
for i = 1:nInst
    actionFound = 0;
    for a = 1:nActions
        if all(A(i,:)==actions(a,:))
            actionFound = 1;
            for n = 1:nNodes
                NLL(i) = NLL(i) - log(mu(n,X(i,n),a));
            end
        end
    end
    if ~actionFound
        % This is an action that was not present in training
        NLL(i) = -nNodes*log(1/nStates);
    end
end
end