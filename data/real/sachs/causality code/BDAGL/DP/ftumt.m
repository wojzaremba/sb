function [hn] = ftumt(h0, k)
% Fast Truncated Upwards Mobius Transform 

lh0 = length(h0);
n = round(log2(lh0));

mask = zeros(1,lh0);
mask(2.^((0:n-1))+1) = 1;
mask = fumt(mask);
h0(mask>k) = 0;

hn = fumt(h0);