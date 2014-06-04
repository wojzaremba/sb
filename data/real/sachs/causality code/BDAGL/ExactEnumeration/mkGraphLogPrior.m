function [Gprior nConsistentOrders] = mkGraphLogPrior(n, k, rho, dags)
% Gprior(g) = sum_orders prod_i q(U_i) rho(G_i)
% We assume q(U_i)=1
% Not recommended for n>5

if nargin < 2, k = n-1; end

if nargin < 3,
	rho = mkAllFamilyLogPrior(n,k);
end

if nargin < 4
	dags = mkAllDags(n);
end

orders = perms(1:n);
nDags = size(dags,1);
Gprior = -Inf*ones(1, nDags);
nConsistentOrders = zeros(size(Gprior));
validPs = cell(1,n);
for oi=1:size(orders,1)
	order = orders(oi,:);
	for i=1:n
		ndx  = find(order==i);
		validPs{i} = sum(2.^(order(1:ndx-1)-1));
	end
	for g=1:nDags
		% tmp = prod_i rho_i(G_i) if all Gi are compatible with order
		tmp = 0;
		invalid = false;
		for i=1:n
			ps = parents( char2dag(char(dags(g,:)),n), i);
			psInd = sum(2.^(ps-1));
			if bitor(validPs{i}, psInd)~=validPs{i}
				invalid = true;
				break
			end
			tmp = tmp + rho(i, psInd+1);
		end
		if ~invalid
			Gprior(g) = logadd(Gprior(g), tmp);
			nConsistentOrders(g) = nConsistentOrders(g) + 1;
		end
	end
	if mod(oi,5)==0
		fprintf('%i/%i\n', oi, size(orders,1));
	end
end
Gprior = Gprior - logsumexp(Gprior);
