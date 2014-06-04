function plot_all_cond_sets(set)

figure;
nbins = 30;

for s = 1:length(set)
    subplot(3,3,s)
    hold on;
    hist(set{s}.p, nbins);
    title(sprintf('all, size %d',s-1), 'fontsize', 16);
    yl{s} = ylim;
    ylim([0 yl{s}(2)/4]);
end

for s = 1:length(set)
    subplot(3,3,3+s)
    hold on;
    hist(set{s}.p(find(set{s}.ind)),nbins);
    title(sprintf('indep., size %d',s-1), 'fontsize', 16);
    %ylim([0 yl{s}(2)]);
end

for s = 1:length(set)
    subplot(3,3,6+s)
    hold on;
    hist(set{s}.p(find(set{s}.edge)),nbins);
    title(sprintf('direct dep., size %d',s-1), 'fontsize', 16);
    yl = ylim;
    ylim([0 yl(2)/10]);
    xlim([0 1]);
end

