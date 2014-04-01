function AUC = plot_auc(TPR,FPR,params)

TPR = squeeze(mean(TPR,1));
FPR = squeeze(mean(FPR,1));
AUC = auc(FPR,TPR);

[A,E] = meshgrid(params.eta,params.alpha);
size(A)
size(E)
size(AUC)

surf(E',A',AUC);