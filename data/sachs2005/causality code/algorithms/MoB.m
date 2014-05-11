function model = factorGraph_exp_Bernoulli(Y,nComponents,dirPrior,nRestarts, ignore, ignore2)

if nargin < 4
    nRestarts = 1;
end

nStates = max(Y(:));

minScore = inf;
for i = 1:nRestarts
    fprintf('Restart = %d\n',i);
    [mu_sub,pi_sub] = fitMixBernoulli(Y,nStates,nComponents,dirPrior);
    
    model.mu = mu_sub;
    model.pi = pi_sub;
    NLL = sum(nll(model,Y));
    
    if NLL < minScore
        fprintf('New Best\n');
        minScore = NLL;
        mu = mu_sub;
        pi = pi_sub;
    end
end

model.nStates = nStates;
model.pi = pi;
model.mu = mu;
model.nll = @nll;
model.nll_unnormalized = @nll;
model.activations = @activate;

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


maxiter = 49;

% Run EM
verbose = 1;
iter = 0;
useMex = 0;

    NLL_old = inf;
while 1
    % Compute NLL
    if verbose==2
        NLL = negativeLogLikelihood(Y,mu,pi);
        fprintf('NLL = %f\n',NLL);

        % Check Convergence
        if NLL > NLL_old
            fprintf('NLL increased\n');
            break;
        elseif NLL_old-NLL < 1e-4
            fprintf('NLL decreasing by less than optTol\n');
            break;
        end
        NLL_old = NLL;
    elseif verbose == 1
        fprintf('iter = %d\n',iter);
    end
    
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
        gamma = gamma./repmat(sum(gamma,2),[1 nComponents]);
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

function NLL = nll(model,Y, ignore)
useMex = 1;

if useMex
    NLL = zeros(size(Y,1),1);
    MoB_nll(int32(Y),model.pi,model.mu,NLL);
else
    NLL = computeNLL(Y,model.mu,model.pi);
end
end

function activations = activate( model, Y )
    mu = model.mu;
    pi = model.pi;
    
    [nInstances,nNodes] = size(Y);
    nComponents = length(pi);
    
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
    gamma = gamma./repmat(sum(gamma,2),[1 nComponents]);
    
    activations = gamma;
end