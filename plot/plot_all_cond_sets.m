function plot_all_cond_sets(set)

for s = 1:length(set)
   subplot(3,3,s)
    hold on;
   hist(set{s}.p);
   title(sprintf('size %d',s-1), 'fontsize', 16);
   yl{s} = ylim;
end

for s = 1:length(set)
    subplot(3,3,3+s)
    hold on;
   hist(set{s}.p(find(set{s}.ind)));
   title(sprintf('independent, size %d',s-1), 'fontsize', 16);
   ylim([0 yl{s}(2)]);
end

for s = 1:length(set)
    subplot(3,3,6+s)
    hold on;
   hist(set{s}.p(find(set{s}.edge)));
   title(sprintf('direct dependence, size %d',s-1), 'fontsize', 16);
   ylim([0 yl{s}(2)]);
   xlim([0 1]);
end

