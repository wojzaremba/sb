function b = isDagOrderConsistent(dag, order)
% check if dag is consistent with order

b = true;
for ni=1:length(dag)
	
	validPs = order(1:find(order==ni));
	ps = find(dag(:, ni));

	validPs2 = sum(2.^(validPs-1));
	ps2 = sum(2.^(ps-1));
	
	b = bitor(ps2, validPs2)<=validPs2;
		
	if ~b		
		b = false;
		break;
	end
	
end