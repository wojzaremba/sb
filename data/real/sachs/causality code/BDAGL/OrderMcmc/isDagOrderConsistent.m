function b = isDagOrderConsistent(dag, order)
% check if dag is consistent with order

[v o] = sort(order);

for ni=1:length(dag)
	
	validPs = order(1:o(ni));	
	ps = find(dag(:, ni));

	validPs2 = sum(2.^(validPs-1));
	ps2 = sum(2.^(ps-1));
	
	b = bitor(ps2, validPs2)>validPs2;
		
	if b
		b = false;
		return;
	end
	
end

b = true;
