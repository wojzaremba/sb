function [testLik] = GraphParams(Xtrain,Xtest,adjMatrix,complexityFactor,discrete,clamped)
% Discrete should be 0 or 1 here

p = length(adjMatrix);
testLik = zeros(p,1);
for i = 1:p
    %fprintf('Evaluating node %d of %d\n',i,p);
    parents = adjMatrix(:,i) == 1;
    testLik(i) = FamilyParams(Xtrain,Xtest,adjMatrix,complexityFactor,discrete,clamped,i);
end
end

function [testLik] = FamilyParams(Xtrain,Xtest,adjMatrix,complexityFactor,discrete,clamped,i)
parents = find(adjMatrix(:,i));
if discrete
    % Compute parameters
    Xsub = [ones(length(Xtrain(clamped(:,i)==0,1)),1) Xtrain(clamped(:,i)==0,parents)];
    ysub = Xtrain(clamped(:,i)==0,i);
    params = L2LogReg_IRLS(Xsub,ysub);
    
    % Compute test set likelihood
    testLik = LLoss(params,[ones(size(Xtest,1),1) Xtest(:,parents)],Xtest(:,i));
else
    % Compute parameters
    Xsub = Xtrain(clamped(:,i)==0,parents);
    ysub = Xtrain(clamped(:,i)==0,i);
    params = (Xsub'*Xsub)\(Xsub'*ysub);
    
    % Compute test set likelihood
    Xsub = Xtest(:,parents);
    ysub = Xtest(:,i);
    testLik = GLoss(Xsub'*Xsub,Xsub'*ysub,ysub'*ysub,params);
end
end