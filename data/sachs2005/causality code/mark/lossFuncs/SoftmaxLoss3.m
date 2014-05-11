function [nll,g,H] = SoftmaxLoss3(w,X,y,k)
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
nll = -(sum(X.*w(:,y).',2) - log(Z));
