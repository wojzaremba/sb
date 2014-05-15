function [y, minx, rangex] = rescaleData(x, minVal, maxVal, minx, rangex)
% rescale columns to lie in the range minVal:maxVal (defaults to -1:1)

x = double(x);
[n d] = size(x);
if nargin < 2
  minVal = -1; maxVal = 1;
end
if nargin < 4
  minx = min(x,[],1); rangex = range(x,1);
end
% rescale to 0:1
y = (x-repmat(minx,n,1)) ./ repmat(rangex, n, 1);
% rescale to 0:(max-min)
y = y * (maxVal-minVal);
% shift to min:max
y = y + minVal;