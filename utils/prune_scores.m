function S = prune_scores(S)
fprintf('prune_scores..\n');

% first remove infs
for i = 1:length(S)
    keep = [];
    for j = 1:length(S{i})
        if isinf(S{i}{j}.score)
            % check that it's negative
            assert(S{i}{j}.score < 0);
            fprintf('***Removing infinite score from S\n');
        else
            keep = [keep j];
        end
    end
    S{i} = S{i}(keep);
end

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
    printf(2, 'finished i = %d\n', i);
end

% % naive approach
% for i = 1:length(S)
%     S{i} = S{i}(end:-1:1); % reverse
%     % start at the end, where the smaller subsets are
%     ni = length(S{i});
%     to_remove = [];
%     for j = 1:ni
%         for k = j-1:-1:1
%             % check if parents of S_ij are a subset of parents of S_ik
%            if ( isempty(S{i}{j}.parents) || isequal(S{i}{j}.parents, ...
%                    intersect(S{i}{j}.parents,S{i}{k}.parents)) )
%                % if the smaller subset has a better (larger) score, then
%                % don't need the larger subset
%                if S{i}{j}.score >= S{i}{k}.score
%                    to_remove(end+1) = k;
%                end
%            end
%         end
%     end
%     keep = setdiff(1:ni,unique(to_remove));
%     S{i} = S{i}(keep);
%     S{i} = S{i}(end:-1:1); % reverse again
%     printf(2, 'finished i = %d\n', i);
% end

fprintf('..finished pruning scores\n');
end
