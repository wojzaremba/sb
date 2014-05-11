disp('test_learn_mrf...');

randn('seed', 1);
rand('seed', 1);

nvec = [5 10];
thresholds = 0:1e-3:1;
AUC = NaN*zeros(1, length(nvec));

for n_idx = 1:length(nvec)
    n = nvec(n_idx);
    scores = zeros(2, 2, length(thresholds));
    printf(2, '  n = %d\n', n);
    for i = 1 : 3        
        [edge_rhos, indep_rhos] = learn_mrf('large', n, 300, false);
        scores = scores + compute_mrf_scores(edge_rhos, indep_rhos, thresholds);     
    end
    [FPR, TPR] = scores_to_tpr(scores);
    AUC(n_idx) = auc(FPR, TPR);
end

assert(issorted(-AUC));