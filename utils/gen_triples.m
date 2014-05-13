function triples = gen_triples(K, S)
% Return a list of triples, where each triple represents (X,Y,S), where X and Y are
% the two variables we want to test for independence, conditioning on S.
% 
% INPUTS:
% K is the total number of variables
% S is a vector of conditioning set sizes

S = sort(S);
triples = cell(choose(K,2),1);
t = 1;

for i = 1:K
    for j = i+1:K 
        
        printf(3, 'i=%d, j=%d\n',i,j);
        triples{t} = struct('i',i,'j',j,'cond_set',[]);
        set = [1:(i-1) (i+1):(j-1) (j+1):K];
        
        if isequal(S(1), 0)
           triples{t}.cond_set{1} = []; 
        end
        
        for k = S
            cond_sets = combinations(set, k);
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