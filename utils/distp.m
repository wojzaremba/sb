function dp = distp(x, y, p)

[x1, x2] = size(x);
[y1, y2] = size(y);
if x2 ~= y2
  error('Second dimension should agree');
end

x = repmat(reshape(x, [x1, 1, x2]), [1, y1, 1]);
y = repmat(reshape(y, [1, y1, y2]), [x1, 1, 1]);
dp = sum((abs(x - y).^p), 3);
