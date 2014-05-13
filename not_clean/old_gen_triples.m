function triples = old_gen_triples(K, S_sm, S_lg)
% Return a list of triples, where each triple is (X,Y,S), where X and Y are
% the two variables we want to test for independence, conditioning on S.
% 
% INPUTS:
% K is the total number of variables
% S_sm is the max conditioning set size
% S_lg (default -1) adds conditioning sets of size (K, K-1, ..., K-S_lg).  
assert(0)

if ~exist('S_lg', 'var')
    S_lg = -1;
end

S_sm = min(K-2, S_sm);
S_lg = min(K-2, S_lg);
assert(S_sm + S_lg < K); %otherwise there will be overlap in the sets coming from S_sm and S_lg

triples = cell(choose(K,2),1);
t = 1;

for i = 1:K
    for j = i+1:K 
        
        printf(3, 'i=%d, j=%d\n',i,j);
        triples{t} = struct('i',i,'j',j,'cond_set',[]);
        set = [1:(i-1) (i+1):(j-1) (j+1):K];
        
        % small conditioning sets
        if S_sm >= 0
            triples{t}.cond_set{1} = [];
        end
        for k = 1 : S_sm
            cond_sets = combinations(set, k);
            if (~isempty(cond_sets))
                for c = 1 : size(cond_sets, 1)
                    triples{t}.cond_set{end + 1} = cond_sets(c, :);
                end
            end
        end
        
        % large conditioning sets
        for k = S_lg : -1 : 0 
            cond_sets = combinations(set, k, true); 
            if (~isempty(cond_sets))
                for c = 1 : size(cond_sets, 1)
                    triples{t}.cond_set{end + 1} = cond_sets(c, :);
                end                
            end
        end
        
        t = t + 1;
        
    end
end

end

