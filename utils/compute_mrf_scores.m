function [scores, opt] = compute_mrf_scores(edge_ps, indep_ps, edge_rhos, indep_rhos)

thresholds = 0:1e-3:1;
scores{1} = mrf_score(edge_ps, indep_ps, thresholds);
scores{2} = mrf_score(edge_rhos, indep_rhos, thresholds);
opt{1}.name = 'KCI Gauss kernel, pval';
opt{2}.name = 'KCI Gauss kernel, rho';
opt{1}.color = 'b-';
opt{2}.color = 'g--';

end


function scores = mrf_score(edge_stats, indep_stats, thresholds)

scores = zeros(2, 2, length(thresholds));

for i = 1:length(edge_stats)
    
    classes = threshold(thresholds, edge_stats(i));
    classes = reshape(classes, [1 1 size(classes)]);
    scores(1, 1, :) = scores(1, 1, :) + ~classes;
    scores(1, 2, :) = scores(1, 2, :) + classes;
    
    classes = threshold(thresholds, indep_stats(i));
    classes = reshape(classes, [1 1 size(classes)]);
    scores(2, 1, :) = scores(2, 1, :) + ~classes;
    scores(2, 2, :) = scores(2, 2, :) + classes;
    
end

end
