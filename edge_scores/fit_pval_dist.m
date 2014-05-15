function [f, x, z, bw, uu] = fit_pval_dist(plot_flag, z_or_filename)

close all

if ischar(z_or_filename)
    command = sprintf('load edge_scores/out/%s z', z_or_filename);
    eval(command);
else
    z = z_or_filename;
end

% just throw out infinite values (and transpose)
printf(2, '  throwing out %d inf values\n', length(find(isinf(z))));
z = z(~isinf(z))';

% histogram plus density with default bandwidth
if plot_flag, a1 = subplot(2,1,1); end
[ff,xx] = ecdf(z);
if plot_flag
    ecdfhist(ff,xx, 20);
    a = findobj(gca,'type','patch');
    set(a(end),'facecolor',[.9 .9 1])
end
[f0,x0,u] = ksdensity(z);
if plot_flag, line(x0, f0, 'color', 'b'); end

% try other bandwidths
uu = linspace(u/3, 2*u, 11);
if plot_flag, subplot(2, 2, 3); end
v = zeros(size(uu));
% using same partition each time reduces variation
cp = cvpartition(length(z), 'kfold', 10);
printf(2, 'cross validating bandwidth..\n');
for j=1:length(uu)
    printf(2, '  fold = %d\n', j);
    % compute log likelihood for test data based on training data
    loglik = @(xtr, xte) sum(log(ksdensity(xtr, xte, 'width', uu(j))));
    % sum across all train/test partitions
    v(j) = sum(crossval(loglik, z, 'partition', cp));
    % plot the fit to the full dataset
    [f,xi] = ksdensity(z, 'width', uu(j));
    if plot_flag, h(j) = line(xi, f, 'color', [.75 .75 .75]); end
end

% find and highlight the one that appears best
[maxv,maxi] = max(v);
bw = uu(maxi);
[f,x] = ksdensity(z, 'width', bw);
if plot_flag
    set(h(maxi), 'linewidth', 2, 'color' ,'r');
    h0 = line(x0, f0, 'color', 'b', 'linewidth', 2);
    title('Kernel smooth variation with bandwidth')
    legend([h0 h(maxi)],'Default','Highest log-lik')

    % show the cross-validation values (sum of log likelihoods)
    subplot(2, 2, 4)
    plot(uu, v, 'b-', uu(maxi), v(maxi), 'ro')
    title('Cross-validated log likelihood vs. bandwidth')

    % add it to the histogram display
    line(x, f, 'color', 'r', 'parent', a1)
    legend(a1, 'Histogram', 'Default', 'Cross-validated')
    title(a1, 'Histogram and two kernel-smooth estimates')
end
