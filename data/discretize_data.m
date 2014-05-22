function s = discretize_data(s, num_bins, method)

if ~exist('method', 'var')
    fprintf('using uniform discretization\n');
    method = 'uniform';
end

if num_bins ~= 1 %if num_bins == 1, just return continuous data


    small = 1e-10;
    for i = 1:size(s,1)
        smin = min(s(i,:));
        smax = max(s(i,:));
  
        if strcmpi(method, 'uniform')
            bin_edges = linspace(smin, smax, num_bins+1);
        elseif strcmpi(method, 'quantile')
            bin_edges = [smin quantile(s(i, :), [1:num_bins] * (1/num_bins))];
        else
            error('unexpected value for method');
        end
            
        bin_edges = [ (bin_edges(1) - small) bin_edges(2:end-1) (bin_edges(end) + small)];
        [~,which_bin] = histc(s(i,:), bin_edges);
        for b = 1:num_bins
            s(i,which_bin == b) = b;
        end
    end


end
