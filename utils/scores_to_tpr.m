function [FPR, TPR] = scores_to_tpr(scores)    
    P = scores(2, 1, :) + scores(2, 2, :);
    N = scores(1, 1, :) + scores(1, 2, :);
    TP = scores(2, 2, :);
    FP = scores(1, 2, :);
    TPR = squeeze(TP ./ P);
    FPR =  squeeze(FP ./ N);
end