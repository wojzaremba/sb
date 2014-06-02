function [S, D] = compute_rho_scores(pre, maxK, nfunc)

% number of variables
si = size(pre.K, 3);

% number of data points
n = size(pre.K, 1);

% compute scores
D = ones(si, si, si) * Inf;
[sum0, sum1, sum2, num0, num1, num2] = deal(0);

for i = 1:si
    D(i, i, i) = norm(pre.K(:, :, i));
    sum0 = sum0 + D(i, i, i);
    num0 = num0 + 1;
    for j = 1:si        
        if (i == j)
            continue;
        end
        for k = j:si
            if (i == k)
                continue;
            end
            K = pre.Kyz(:, :, i, j, k);
            D(i, j, k) = norm(K(:))^2;   %<- the only important line of code in this whole function
            D(i, k, j) = D(i, j, k);  
            if (j == k)
                sum1 = sum1 + D(i, j, k);
                num1 = num1 + 1;
            else
                sum2 = sum2 + D(i, j, k);
                num2 = num2 + 1;
            end
        end
    end
end
D = D ./ nfunc(n); %<- okay this one is important too.

% divide by mean over all conditioning set sizes
% E = D(D ~= Inf);
% m = mean(E(:)) / 40;
% D = D ./ m;
% for i = 1:si
%     D(i, i, i) = num0 * D(i, i, i) / sum0;
%     for j = 1:si
%         if (i == j)
%             continue;
%         end
%         for k = j:si
%             if (i == k)
%                 continue;
%             end
%             if (j == k)
%                 D(i, j, k) = num1 * D(i, j, k) / sum1;
%             else
%                 D(i, j, k) = num2 * D(i, j, k) / sum2;
%             end
%         end
%     end
% end


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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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



