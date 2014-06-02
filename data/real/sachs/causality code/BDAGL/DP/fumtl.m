function [hn] = fumtl(h0)
% Fast Upwards Mobius Transform 
% Based on code by Smets, http://iridia.ulb.ac.be/~psmets/

lh0 = length(h0);
n = round(log2(lh0)); 		
if lh0 ~= 2^n
	error('length of h0 must be a power of 2');
end

hn = h0;

for i = 1:n
	i124 = 2^(i-1);
	i842 = 2^(n+1-i);
	i421 = 2^(n - i);
	hn = reshape(hn,i124,i842);
	in = (1:i421)*2;
	hn(:,in) = logadd(hn(:,in),hn(:,in-1));
end

hn = reshape(hn,1,lh0);

