function plot_cpd(CPD,for_title)

plot_simplex;
%add_indep_surface;

CPD_det = squeeze((CPD(1,1,:) .* CPD(2,2,:)) - (CPD(1,2,:) .* CPD(2,1,:)));
indep = CPD(:,:,abs(CPD_det) < eps);
dep = CPD(:,:,abs(CPD_det) >= eps);

hold on

%scatter3(indep(1,1,:),indep(1,2,:),indep(2,1,:),'g*');
%scatter3(dep(1,1,:),dep(1,2,:),dep(2,1,:),'r*');

X = [dep(1,1,:),dep(1,2,:),dep(2,1,:)];
X = squeeze(X);
X = X';

% Compute the histogram
edge = linspace(0,1,50); % change here to your need;
[count, ~, ~, loc] = histcn(X,edge,edge,edge);

% Gaussian smoothing the histogram
kernel = exp(-linspace(0,1,11).^2);
K = 1;
for k=1:3
    K = K(:)*kernel;
end
K = reshape(K,length(kernel)+[0 0 0 ]);
K = K/sum(K(:));
count = convn(count, K,'same');

% Density
density= zeros(size(X,1),1);
valid = all(loc,2);
loc = loc(valid,:);
density(valid) = count(sub2ind(size(count),loc(:,1),loc(:,2),loc(:,3)));

% Plot
scatter3(X(:,1),X(:,2),X(:,3),20,density)
colormap(hot)

if (exist('for_title','var'))
    title(sprintf('Dependent distributions from %s network',for_title),'fontsize',16);
else
    title('Dependent distributions','fontsize',16);
end
