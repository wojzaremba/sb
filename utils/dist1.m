function n2 = dist1(x, c)
[ndata, dimx] = size(x);
[ncentres, dimc] = size(c);
if dimx ~= dimc
	error('Data dimension does not match dimension of centres')
end

x = repmat(reshape(x, [ndata, 1, dimx]), [1, ncentres, 1]);
c = repmat(reshape(c, [1, ncentres, dimc]), [ndata, 1, 1]);
n2 = sum(abs(x - c), 3);