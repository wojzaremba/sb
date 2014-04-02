function [AUC,flag] = plot_auc(TPR,FPR,params,xmax)

TPR = squeeze(mean(TPR,1));
FPR = squeeze(mean(FPR,1));
[AUC,flag] = auc(FPR,TPR,xmax);
fprintf('# of poorly characterized points = %d\n',length(find(flag)));

[A,E] = meshgrid(2.^(params.eta),log10(params.alpha));
%[A,E] = meshgrid(params.eta,params.alpha);
fprintf('length of eta is %d\n',length(params.eta));
fprintf('length of alpha is %d\n',length(params.alpha));

if (xmax==1)
    auc_string = 'AUC';
else
    auc_string = sprintf('pAUC (to %.2f)',xmax);
end

surf(E',A',AUC,'linestyle','none');
xlabel('log_{10}(alpha)','fontsize',14);
ylabel('2^{eta}','fontsize',14);
zlabel(auc_string,'fontsize',14);

%title(sprintf('%s for sb classifier, linear asia network, arity = %d, N = %d',auc_string,arity,num_samples),'fontsize',16);
