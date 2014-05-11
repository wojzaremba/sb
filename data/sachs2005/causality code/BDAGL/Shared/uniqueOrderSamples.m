function [uOrders counts] = uniqueOrderSamples(orders)
% orders: a MxN matrix of orders (M: # of samples, N: # of nodes)
% useful for order-mcmc

uOrders = [];
counts = [];

for si=1:size(orders,1)
	isExist = false;
	for ui=1:size(uOrders,1)
		if all( orders(si,:) == uOrders(ui,:) ), 
			isExist = true; 
			break;
		end
	end
	
	if isExist
		counts(ui) = counts(ui) + 1;
	else
		uOrders(size(uOrders,1)+1,:) = orders(si,:);
		counts(length(counts)+1) = 1;
	end
end

