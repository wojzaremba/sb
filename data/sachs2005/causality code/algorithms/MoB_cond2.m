function model = MoB_cond2(data,nComponents,lambda,lambdaSmall,nRestarts)
% Like MoB_cond, but uses generalized EM

if nargin < 4
   lambdaSmall = 1e-4; 
end

if nargin < 5
    nRestarts = 1;
end

Y = data.X;
[nSamples,nNodes] = size(Y);
nStates = data.nStates;

A = data.A;

minScore = inf;
for i = 1:nRestarts
    fprintf('Restart = %d\n',i);
    [mu_sub,pi_sub] = fitMixBernoulli(Y,A,nStates,nComponents,lambda,lambdaSmall);

    model.mu = mu_sub;
    model.pi = pi_sub;
    model.nStates = nStates;
    NLL = sum(nll(model,data));

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

end

function [mu,pi] = fitMixBernoulli(Y,A,nStates,nComponents,lambda,lambdaSmall)
[nInstances,nNodes] = size(Y);
nActionVars = size(A,2);

% Initialize Variables
pi = rand(1,nComponents);
pi = pi/sum(pi);
mu = rand((1+nActionVars)*(nStates-1),nNodes,nComponents);
for n = 1:nNodes
    for c = 1:nComponents
        % Initialize by setting all parent variables to 0, random bias
        tmp = zeros((1+nActionVars),nStates-1);
        tmp(1,:) = randn(1,nStates-1);
        mu(:,n,c) = tmp(:);
    end
end

maxiter = 100;

% Run EM
verbose = 1;
iter = 0;
useMex = 0;

NLL_old = inf;
options.Display = 'off';
options.maxIter = 15; % Number of evaluations of softmax per component per iteration
w_init = zeros(1+nActionVars,nStates-1);
lambdaMatrix = ones(1+nActionVars,nStates-1);
lambdaMatrix(1,:) = lambdaSmall; % Don't regularize biases
warmStart = 0;
while 1

    if iter >= maxiter
        fprintf('Reached max iterations: %d\n', maxiter );
        break;
    end
    iter = iter + 1;

    % Compute Responsibilities gamma
    fprintf('Computing responsibilities\n');
    gamma = zeros(nInstances,nComponents);
    for c = 1:nComponents
        for n = 1:nNodes
            gamma(:,c) = gamma(:,c) - SoftmaxLoss3(mu(:,n,c),[ones(nInstances,1) A],Y(:,n),nStates);
        end
    end
    gamma = gamma + repmat(log(pi),[nInstances 1]);
    gamma = exp(gamma);
    NLL = sum(-log(sum(gamma,2)));
    gamma = gamma./repmat(sum(gamma,2),[1 nComponents]);

    % Check Convergence
    fprintf('iter = %d, NLL = %f\n',iter,NLL);

    if NLL > NLL_old
        fprintf('NLL increased\n');
        break;
    elseif NLL_old-NLL < 1e-4
        fprintf('NLL decreasing by less than optTol\n');
        break;
    end
    NLL_old = NLL;

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
            warmStart = 0;
            gamma = gamma(:,[1:c-1 c+1:nComponents]);
            N = sum(gamma);
            pi = N/nInstances;
            nComponents = nComponents-1;
        else
            c = c + 1;
        end
    end

    % Update mu
    for c = 1:nComponents
        fprintf('Updating Component %d\n',c);
        for n = 1:nNodes
            %funObj = @(w)SoftmaxLoss2_weighted(w,[ones(nInstances,1) A],Y(:,n),nStates,gamma(:,c));
            Xsub = [ones(nInstances,1) A];
            Ysub = int32(Y(:,n));
            funObjC= @(w)SoftmaxLoss2_weightedC(w,Xsub,Ysub,int32(nStates),gamma(:,c));
            if warmStart
                tmp = mu(:,n,c);
                mu(:,n,c) = minFunc(@penalizedL2,tmp(:),options,funObjC,lambda*lambdaMatrix(:));
            else
                mu(:,n,c) = minFunc(@penalizedL2,w_init(:),options,funObjC,lambda*lambdaMatrix(:));
            end
        end
    end
    warmStart = 1;
end
end


function NLL = nll(model,data)

Y = data.X;
A = data.A;

mu = model.mu;
pi = model.pi;

[nInstances,nNodes] = size(Y);
nComponents = size(mu,3);

gamma = zeros(nInstances,nComponents);
for c = 1:nComponents
    for n = 1:nNodes
        gamma(:,c) = gamma(:,c) - SoftmaxLoss3(mu(:,n,c),[ones(nInstances,1) A],Y(:,n),model.nStates);
    end
end
gamma = gamma + repmat(log(pi),[nInstances 1]);
gamma = exp(gamma);
NLL = -log(sum(gamma,2));
end
