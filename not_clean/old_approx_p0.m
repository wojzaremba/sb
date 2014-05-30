function p0 = approx_p0(f, x, mu, sigma)
% estimate the coefficient of the mixture component corresponding to
% independence.  Based on the suggestion from Efron 2003, Remark E.

% c = 0.8;
% bds = [mu - c*sigma, mu + c*sigma];
% assert(bds(1) >= min(x));
% assert(bds(2) <= max(x));
% idx = find((x >= bds(1)) .* (x <= bds(2)));
% 
% % compute pi(c)
% fbds = interp1(x,f,bds);
% xx = [bds(1) x(idx) bds(2)];
% ff = [fbds(1) f(idx) fbds(2)];
% pi_c = trapz(xx, ff);
% 
% p0 = pi_c / (2*normcdf(c, mu, sigma) - 1);

% THIS METHOD SUCKS!
% Instead, look at f(mu), and choose the maximum p0 so that compare_curves(x, f, x, p0*normcdf(x, mu,
% sigma) is true.

p = linspace(0,1,101);
still_under = true;
y = normpdf(x, mu, sigma);
idx = 1;

while (still_under && idx <= 101)
    still_under = compare_curves(x, f, x, p(idx)*y);
    idx = idx + 1;
end

p0 = p(idx-1);
    
