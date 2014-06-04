function [nll,g,H] = SoftmaxLoss2(w,X,y,k,weights)
% w(feature*class,1) - weights for last class assumed to be 0
% X(instance,feature)
% y(instance,1)
%
% version of SoftmaxLoss where weights for last class are fixed at 0
%   to avoid overparameterization

[n,p] = size(X);
w = reshape(w,[p k-1]);
w(:,k) = zeros(p,1);

Z = sum(exp(X*w),2);
nll = -sum(weights.*(sum(X.*w(:,y).',2) - log(Z)));

if nargout > 1
    g = zeros(p,k-1);

    for c = 1:k-1
        g(:,c) = -sum(repmatC(weights,[1 p]).*X.*repmatC((y==c) - exp(X*w(:,c))./Z,[1 p]));
    end
    g = reshape(g,[p*(k-1) 1]);
end
