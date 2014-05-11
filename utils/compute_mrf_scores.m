function scores = compute_mrf_scores(edge_rhos, indep_rhos, thresholds)

if ~exist('thresholds', 'var')
    thresholds = 0:1e-4:1;
end

scores = mrf_score(edge_rhos, indep_rhos, thresholds);

end


function scores = mrf_score(edge_stats, indep_stats, thresholds)

scores = zeros(2, 2, length(thresholds));

for i = 1:length(edge_stats)
    
    classes = threshold(thresholds, edge_stats(i));
    classes = reshape(classes, [1 1 size(classes)]);
    scores(1, 1, :) = scores(1, 1, :) + ~classes;
    scores(1, 2, :) = scores(1, 2, :) + classes;
    
end

for i = 1: length(indep_stats)
    
    classes = threshold(thresholds, indep_stats(i));
    classes = reshape(classes, [1 1 size(classes)]);
    scores(2, 1, :) = scores(2, 1, :) + ~classes;
    scores(2, 2, :) = scores(2, 2, :) + classes;
    
end

end
