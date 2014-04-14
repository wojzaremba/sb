function s = discretize(s,num_bins)

small = 1e-10;

for i = 1:size(s,1)
    smin = min(s(i,:));
    smax = max(s(i,:));
    bin_edges = linspace(smin,smax,num_bins+1);
    bin_edges(1) = bin_edges(1) - small;
    bin_edges(end) = bin_edges(end) + small;
    [~,which_bin] = histc(s(i,:),bin_edges);
    for b = 1:num_bins
        s(i,which_bin == b) = b;
    end
end