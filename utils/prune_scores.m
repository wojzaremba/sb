function S = prune_scores(S)

% naive approach
for i = 1:length(S)
    % start at the end, where the smaller subsets are
    ni = length(S{i});
    to_remove = [];
    for j = ni:-1:1
        for k = j-1:-1:1
            % check if parents of S_ij are a subset of parents of S_ik
           if ( isempty(S{i}{j}.parents) || isequal(S{i}{j}.parents, ...
                   intersect(S{i}{j}.parents,S{i}{k}.parents)) )
               % if the smaller subset has a better (larger) score, then
               % don't need the larger subset
               if S{i}{j}.score >= S{i}{k}.score
                   to_remove(end+1) = k;
               end
           end
        end
    end
    keep = setdiff(1:ni,unique(to_remove));
    S{i} = S{i}(keep);
end
