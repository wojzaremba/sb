function model = MoB_ind(data,nComponents,dirPrior,nRestarts)

if nargin < 4
    nRestarts = 1;
end

Y = data.X;
[nInst,nNodes] = size(Y);
nStates = data.nStates;

% Sort actions
A = data.A;
[A,ind] = sortrows(A);
Y = Y(ind,:);

action = 1;
actionStart = 1;
for i = 1:nInst
    if i < nInst && ~all(A(i,:)==A(i+1,:));
        actionEnd = i;
        [mu{action},pi{action}] = fit(Y(actionStart:actionEnd,:),nStates,nComponents,dirPrior,nRestarts);
        
       action = action+1;
       actionStart = i+1;
    end
    if i == nInst
       actionEnd = i; 
       [mu{action},pi{action}] = fit(Y(actionStart:actionEnd,:),nStates,nComponents,dirPrior,nRestarts);
    end
end

model.nStates = nStates;
model.actions = unique(A,'rows');
model.pi = pi;
model.mu = mu;
model.nll = @nll;
model.nll_unnormalized = @nll;

end

function [mu,pi] = fit(Y,nStates,nComponents,dirPrior,nRestarts)
minScore = inf;
for i = 1:nRestarts
    fprintf('Restart = %d\n',i);
    [mu_sub,pi_sub] = fitMixBernoulli(Y,nStates,nComponents,dirPrior);
    
    model.mu = mu_sub;
    model.pi = pi_sub;
    NLL = sum(computeNLL(Y,mu_sub,pi_sub));
    
    if NLL < minScore
        fprintf('New Best\n');
        minScore = NLL;
        mu = mu_sub;
        pi = pi_sub;
    end
end
end

function [mu,pi] = fitMixBernoulli(Y,nStates,nComponents,dirPrior)
[nInstances,nNodes] = size(Y);

% Initialize Variables
pi = rand(1,nComponents);
pi = pi/sum(pi);
mu = rand(nNodes,nStates,nComponents);
for n = 1:nNodes
    for c = 1:nComponents
        mu(n,:,c) = mu(n,:,c)/sum(mu(n,:,c));
    end
end


maxiter = 100;

% Run EM
verbose = 1;
iter = 0;
useMex = 0;

    NLL_old = inf;
while 1
    
    if iter >= maxiter
            fprintf('Reached max iterations: %d\n', maxiter );
            break;
    end
    iter = iter + 1;

    % Compute Responsibilities gamma
    if useMex
        gamma = ones(nInstances,nComponents);
        MoB_updateGamma(int32(Y),pi,mu,gamma);
    else
        gamma = zeros(nInstances,nComponents);
        for i = 1:nInstances
            for c = 1:nComponents
                for n = 1:nNodes
                    gamma(i,c) = gamma(i,c)+log(mu(n,Y(i,n),c));
                end
            end
        end
        gamma = gamma + repmat(log(pi),[nInstances 1]);
        gamma = exp(gamma);
        NLL = sum(-log(sum(gamma,2)));
        gamma = gamma./repmat(sum(gamma,2),[1 nComponents]);
    end
    
    % Check Convergence
    if useMex
        fprintf('iter = %d\n',iter);
    else
        fprintf('iter = %d, NLL = %f\n',iter,NLL);

        if NLL > NLL_old
            fprintf('NLL increased\n');
            break;
        elseif NLL_old-NLL < 1e-4
            fprintf('NLL decreasing by less than optTol\n');
            break;
        end
        NLL_old = NLL;
    end
    
    % Update pi
    N = sum(gamma);
    pi = N/nInstances;

    % Remove clusters that explain no data points
    c = 1;
    while 1
        if c > nComponents
            break;
        end

        if N(c) < 1e-10
            fprintf('Removing Degenerate Cluster\n');
            clear mu
            gamma = gamma(:,[1:c-1 c+1:nComponents]);
            N = sum(gamma);
            pi = N/nInstances;
            nComponents = nComponents-1;
        else
            c = c + 1;
        end
    end

    % Update mu
    if useMex
        mu = zeros(nNodes,nStates,nComponents);
        MoB_updateMu(int32(Y),N,mu,gamma,dirPrior);
    else
        for c = 1:nComponents
            for n = 1:nNodes
                for s = 1:nStates
                    mu(n,s,c) = (1/N(c))*sum(gamma(:,c).*(Y(:,n)==s));

                    % Add one fake example
                    %mu(n,s,c) = mu(n,s,c)*N(c)/(N(c)+nStates) + 1/(N(c)+nStates);
                    mu(n,s,c) = mu(n,s,c)*N(c)/(N(c)+dirPrior) + dirPrior/(N(c)+dirPrior);
                end
                mu(n,:,c) = mu(n,:,c)/sum(mu(n,:,c));
            end
        end
    end
end
end


function [NLL] = negativeLogLikelihood(Y,mu,pi)
    NLL = sum(computeNLL(Y,mu,pi));
end

function [NLL] = computeNLL(Y,mu,pi)
[nInstances,nNodes] = size(Y);
nComponents = length(pi);

NLL = zeros(nInstances,1);
for i = 1:nInstances
    p_x = 0;
    for c = 1:nComponents
        log_p_x_mu = 0;
        for n = 1:nNodes
            log_p_x_mu = log_p_x_mu+log(mu(n,Y(i,n),c));
        end
        log_p_x_mu = log_p_x_mu+log(pi(c));
        p_x = p_x + exp(log_p_x_mu);
    end
    NLL(i) = NLL(i) - log(p_x);
end
end

function NLL = nll(model,data)

Y = data.X;
[nInst nNodes] = size(Y);

A = data.A;
nStates = data.nStates;

actions_train = model.actions;
nActions = size(actions_train,1);

actions_test = unique(A,'rows');

NLL = zeros(nInst,1);
for a = 1:size(actions_test,1)
    actionNdx = find(all(A == repmat(actions_test(a,:),[nInst 1]),2));
    
    actionFound = 0;
    for atrain = 1:nActions
        if all(actions_test(a,:)==actions_train(atrain,:))
            actionFound = 1;
            NLL(actionNdx) = computeNLL(Y(actionNdx,:),model.mu{atrain},model.pi{atrain});
        end
    end
    if ~actionFound
        % This is an action that was not present in training
        NLL(actionNdx) = -nNodes*log(1/nStates);
    end
end
end
