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
    %no parents
    S{i}{end + 1} = struct('score', -D(i, i, i), 'parents', []);      
    
    % one parent
    for j = 1:si
        if (j == i) % don't condition i on i
            continue;
        end
        S{i}{end + 1} = struct('score', -D(i, j, j), 'parents', j);
    end
    
    % two parents
    [d, j, k] = get_maxK_elts(squeeze(D(i, :, :)), maxK, i);
    for t = 1:length(d)
        assert(d(t) == D(i, j(t), k(t)));
        S{i}{end + 1} = struct('score', -d(t), 'parents', [j(t), k(t)]);
    end

    % flip order for prune scores
    S{i} = S{i}(end:-1:1); 
end

% check for inf scores
for i = 1:length(S)
    for j = 1:length(S{i})
        assert(~isinf(S{i}{j}.score));
    end
end

function [d, j, k] = get_maxK_elts(D, maxK, i)
%pass squeeze D(i, :, :)

[K, J] = meshgrid(1:si, 1:si);

% extract vector containing all elements above diagonal
j = J(logical(triu(D, 1)));
k = K(logical(triu(D, 1)));
d = D(logical(triu(D, 1)));

% remove infs
j = j(~isinf(d));
k = k(~isinf(d));
d = d(~isinf(d));

% make sure i is not a parent of i
assert(all(j ~= i));
assert(all(k ~= i));

% sort and take smallest maxK values
[d, idx] = sort(d);
if length(d) >= maxK
    j = j(idx(1:maxK));
    k = k(idx(1:maxK));
    d = d(1:maxK);
else
    j = j(idx);
    k = k(idx);
end

printf(2, 'taking %d two-parent sets\n', length(d)); 

end

end

% take 1      
%         [~, order] = sort(D(i, j, j+1:end));
%         for k = 1 : maxK
%             o = order(k);
%             if (D(i, j, o) ~= Inf)
%                 S{i}{end + 1} = struct('score', -D(i, j, o), 'parents', unique([j, o]));
%             end
%         end

% take 2
%     for j = 1:si
%         for k = j+1:si
%             if ((j == i) || (k == i)) % don't condition i on i
%                 continue;
%             end
%             S{i}{end+1} = struct('score', -D(i, j, k), 'parents', [j k]);
%         end
%     end



