function [S, D] = compute_rho_scores(pre, maxK)

% number of variables
si = size(pre.K, 3);

% compute scores
D = ones(si, si, si) * Inf;
for i = 1:si
    D(i, i, i) = norm(pre.K(:, :, i));
    for j = 1:si        
        if (i == j)
            continue;
        end
        for k = j:si
            if (i == k)
                continue;
            end
            K = pre.Kyz(:, :, i, j, k);
            D(i, j, k) = norm(K(:));
            D(i, k, j) = D(i, j, k);            
        end
    end
end

% save to structure
S = cell(si, 1);
for i = 1:si
    S{i} = {};
    S{i}{end + 1} = struct('score', -D(i, i, i), 'parents', []);      
    for j = 1:si
        if (j == i) % don't condition i on i
            continue;
        end
        S{i}{end + 1} = struct('score', -D(i, j, j), 'parents', j);
    end
    for j = 1:si
        for k = j+1:si
            if ((j == i) || (k == i)) % don't condition i on i
                continue;
            end
            S{i}{end+1} = struct('score', -D(i, j, k), 'parents', [j k]);
        end
    end
    S{i} = S{i}(end:-1:1); % flip order for prune scores
end

end

%         for k = 1:si
%             if (j == k)
%                 continue;
%             end
%             S{i}{end + 1} = struct('score', -D(i, j, k), 'parents', [j k]);
%         end
%         
%         [~, order] = sort(D(i, j, :));
%         for k = 1 : maxK
%             o = order(k);
%             if (D(i, j, o) ~= Inf)
%                 S{i}{end + 1} = struct('score', -D(i, j, o), 'parents', unique([j, o]));
%             end
%         end



