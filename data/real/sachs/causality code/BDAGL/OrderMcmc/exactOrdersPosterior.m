function [post allOrders] = exactOrdersPosterior( allFamilyLogScore )
% compute the exact posterior over orders
% be careful on how many nodes this is called on since there are #nodes!
% orders
% allFamilyLogScore = allFamilyLogMargLik, allFamilyLogPrior


nNodes = size(allFamilyLogScore, 1);

nOrders = factorial(nNodes);
allOrders = perms(1:nNodes);
post = zeros(1, nOrders);

for pi = 1:nOrders
	post(pi) = logMargLikOrder( allOrders(pi,:), allFamilyLogScore );
end

post = exp(post - logsumexp(post));