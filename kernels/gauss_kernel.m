function ret = gauss_kernel(x, y, theta)
n2 = dist2(x, y);
if theta(1)==0
    theta(1)=2/median(n2(tril(n2)>0));
end
wi2 = theta(1)/2;
ret = theta(2)*exp(-n2*wi2);
   
