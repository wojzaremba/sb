function plot_sachs_data(D1, D2)

figure
for i = 1:11
   subplot(3,4,i)
   hist(D1(:,i),30);
   title(sprintf('Cond 1 V%d',i),'fontsize',14);
end

figure
for i = 1:11
   subplot(3,4,i)
   hist(D2(:,i),30);
   title(sprintf('Cond 2 V%d',i),'fontsize',14);
end