function [score,model] = graphLearn_fitCPD(Y,child,parents,likelihood,select,nStates,clamped,subOptions)

options.Display = 'none';
options.verbose = 0;

% Make X and y
if isempty(clamped)
    X = Y(:,parents);
    y = Y(:,child);
else
    X = Y(clamped(:,child)==0,parents);
    y = Y(clamped(:,child)==0,child);
end

[nInstances,nVars] = size(X);
switch likelihood
    case 'Gaussian'
        modelFunc = @graphLearn_CPDgaussian;
    case 'Student'
        modelFunc = @graphLearn_CPDstudent;
    case 'Probit'
        modelFunc = @graphLearn_CPDbinary;
        subOptions.link = 'probit';
        X = [ones(nInstances,1) X];
    case 'Logistic'
        modelFunc = @graphLearn_CPDbinary;
        X = [ones(nInstances,1) X];
    case 'Ordinal'
        modelFunc = @graphLearn_CPDordinal;
        subOptions.nStates = nStates(child);
        X = [ones(nInstances,1) X];
    case 'Softmax'
        modelFunc = @graphLearn_CPDsoftmax;
        subOptions.nStates = nStates(child);

        nStatesX = nStates(parents);
        Xnew = zeros(nInstances,sum(nStatesX));
        for i = 1:nInstances
            offset = 1;
            for v = 1:nVars
                Xnew(i,offset+X(i,v)-1) = 1;
                offset = offset+nStatesX(v);
            end
        end
        
        % Make groups for finding out which variable comes from which
        % parent
        groups = zeros(sum(nStatesX),1);
        offset = 1;
        for v = 1:nVars
            groups(offset:offset+nStatesX(v)-1) = v;
            offset = offset+nStatesX(v);
        end
        groups = [0;groups];
        subOptions.groups = groups;
        
        X = [ones(nInstances,1) Xnew];
    case {'Ordinal2','Ordinal3'}
        modelFunc = @graphLearn_CPDordinal;
        subOptions.nStates = nStates(child);

        nStatesX = nStates(parents);
        Xnew = zeros(nInstances,sum(nStatesX));
        for i = 1:nInstances
            offset = 1;
            for v = 1:nVars
                if strcmp(likelihood,'Ordinal2')
                Xnew(i,offset+X(i,v)-1) = 1;
                else
                Xnew(i,offset:offset+X(i,v)-1) = 1;
                end
                offset = offset+nStatesX(v);
            end
        end
        
        % Make groups for finding out which variable comes from which
        % parent
        groups = zeros(sum(nStatesX),1);
        offset = 1;
        for v = 1:nVars
            groups(offset:offset+nStatesX(v)-1) = v;
            offset = offset+nStatesX(v);
        end
        groups = [0;groups];
        subOptions.groups = groups;
        
        X = [ones(nInstances,1) Xnew];
    otherwise
        assert(1==0,'Unrecognized likelihood');
end

switch select
    case 'CV' % cross-validation score
        [ndx1,ndx2,randState,randnState] = prepareCV(nInstances);

        % Compute testErr1 and testErr2
        model = modelFunc(X(ndx1,:),y(ndx1),subOptions);
        testErr1 = -model.loglik(model,X(ndx2,:),y(ndx2));

        model = modelFunc(X(ndx2,:),y(ndx2),subOptions);
        testErr2 = -model.loglik(model,X(ndx1,:),y(ndx1));
        score = testErr1+testErr2;

        if nargout > 1
            % Find MLE weights
            model = modelFunc(X,y,subOptions);
        end

        rand('state',randState);
        randn('state',randnState);
    case 'L2CV' % cross-validation score, searching over L2 prior strength
        [ndx1,ndx2,randState,randnState] = prepareCV(nInstances);

        score = inf;
        for lambdaL2 = 2.^[8:-1:-8]

            % Compute testErr1 and testErr2
            subOptions.lambdaL2 = lambdaL2;

            model = modelFunc(X(ndx1,:),y(ndx1),subOptions);
            testErr1 = -model.loglik(model,X(ndx2,:),y(ndx2));

            model = modelFunc(X(ndx2,:),y(ndx2),subOptions);
            testErr2 = -model.loglik(model,X(ndx1,:),y(ndx1));

            if testErr1+testErr2 < score
                score = testErr1+testErr2;
                bestLambda = lambdaL2;
            end
        end
        bestLambda = bestLambda*2;

        if nargout > 1
            subOptions.lambdaL2 = 2*bestLambda;
            model = modelFunc(X,y,subOptions);
        end
        rand('state',randState);
        randn('state',randnState);
    case 'L1CV' % cross-validation score, searching over L1 prior strength
        [ndx1,ndx2,randState,randnState] = prepareCV(nInstances);

        score = inf;
        for lambdaL1 = 2.^[8:-1:-8]
            lambdaL1
            subOptions.lambdaL1 = lambdaL1;

            model = modelFunc(X(ndx1,:),y(ndx1),subOptions);
            testErr1 = -model.loglik(model,X(ndx2,:),y(ndx2));

            model = modelFunc(X(ndx2,:),y(ndx2),subOptions);
            testErr2 = -model.loglik(model,X(ndx1,:),y(ndx1));

            if testErr1+testErr2 < score
                score = testErr1+testErr2;
                bestLambda = lambdaL1;
            end
        end
        bestLambda = 2*bestLambda;

        if nargout > 1
            subOptions.lambdaL1 = 2*bestLambda;
            model = modelFunc(X,y,subOptions);
        end

        rand('state',randState);
        randn('state',randnState);
    case 'Marginal' % Marginal likelihood, searching over L2 prior strength
        assert(strcmp(likelihood,'Gaussian'),'Marginal Likelihood only implemented for Gaussian');
        
        score = inf;
        for lambdaL2 = 2.^[8:-1:-8]

            % Compute negative marginal likelihood
            if 0 % explicitly form sigma
                sigma = X*X' + lambdaL2*eye(nInstances);
                subScore = (nInstances/2)*log(2*pi) + (1/2)*logdet(sigma) + (1/2)*y'*(sigma\y);
            else % use matrix-inversion and matrix-determinant lemmas (for n > p)
                invSigmaY = (y - X*((eye(nVars) + (1/lambdaL2)*X'*X)\(X'*y/lambdaL2)))/lambdaL2;
                logDetTerm = nInstances*log(lambdaL2) + logdet(eye(nVars) + (1/lambdaL2)*X'*X);
                subScore = (nInstances/2)*log(2*pi) + (1/2)*logDetTerm + (1/2)*y'*invSigmaY;
            end

            if subScore < score
                score = subScore;
                bestLambda = lambdaL2;
            end
        end

        if nargout > 1
            subOptions.lambdaL2 = bestLambda;
            model = modelFunc(X,y,subOptions);
        end
    case 'Laplace' % Laplace approximation to marginal likelihood
        
        score = inf;
        for lambdaL2 = 2.^[8:-1:-8]
            
            % Find mode of distribution
            subOptions.lambdaL2 = lambdaL2;
            model = modelFunc(X,y,subOptions);
            
            % Compute Laplace approximation of negative marginal likelihood
            C = model.HessianFunc(model,X,y);
            nVars = length(C);
            subScore = -model.loglik(model,X,y) - (nVars/2)*log(2*pi) + (1/2)*logdet(C);

            if subScore < score
                score = subScore;
                bestLambda = lambdaL2;
            end
        end

        if nargout > 1
            subOptions.lambdaL2 = bestLambda;
            model = modelFunc(X,y,subOptions);
        end
    otherwise % approaches based on maximum likelihood estimate

        % Compute loglik for MLE
        model = modelFunc(X,y,subOptions);
        loglik = model.loglik(model,X,y);

        switch select
            case 'AIC'
                score = 2*nnz(model.w) - 2*loglik;
            case 'BIC'
                score = -2*loglik + nnz(model.w)*log(nInstances);
            case 'Train'
                score = -loglik;
            case 'RegObj'
                score = -model.regloglik(model,X,y);
                drawnow
        end
end
end

%%
function [ndx1,ndx2,randState,randnState] = prepareCV(nInstances)
randState = rand('state');
randnState = randn('state');
rand('state',0);
randn('state',0);

perm = randperm(nInstances);
ndx1 = perm(1:floor(nInstances/2));
ndx2 = perm(floor(nInstances/2)+1:end);
end

