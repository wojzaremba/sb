function bins = dataToHistogram(data, arities)
% produce a histogram out of discrete data (x-axis of histo corresponds to each possible setting of
% variables)
nNodes = size(data,1);
if length(arities)~=nNodes, error('Consistency error between data and arities'); end

bins = zeros(1, prod(arities));
for di=1:size(data,2)
    ind = subv2ind(arities, data(:,di)');
    bins(ind) = bins(ind) + 1;
end