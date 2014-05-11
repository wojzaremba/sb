function model = bernoulli(Y,dirPrior, ignore, ignore2)

[nSamples,nNodes] = size(Y);
nStates = max(Y(:));

% Train
mu = zeros(nNodes,nStates);
for n = 1:nNodes
    for s = 1:nStates
        mu(n,s) = sum(Y(:,n)==s)+dirPrior;
    end
    mu(n,:) = mu(n,:)/sum(mu(n,:));
end

model.mu = mu;
model.nll = @nll;
model.nll_unnormalized = @nll;

end

function un = un( model, Y )
    un = nll( model, Y ) + 10;   % just useful as a sanity check
end

function NLL = nll(model,Y, ignore)

    % returns per-sample nll
    [nSamples,nNodes] = size(Y);

    mu = model.mu;

    NLL = zeros( nSamples, 1 );

    for s = 1:nSamples
        for n = 1:nNodes
           NLL(s) = NLL(s) - log(mu(n,Y(s,n))); 
        end
    end
end
