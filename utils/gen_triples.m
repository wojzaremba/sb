function triples = gen_triples(K, max_S)
% Return a list of triples, where each triple is (X,Y,S), where X and Y are
% the two variables we want to test for independence, conditioning on S.
% 
% INPUTS:
% max_S is the max conditioning size

max_S = min(K-2,max_S);
triples = cell(0);
for i = 1:K
    for j = i+1:K        
        printf(2, 'i=%d, j=%d\n',i,j);
        for k = 0:max_S
            set = [1:(i-1) (i+1):(j-1) (j+1):K];
            cond_sets = combinations(set, k);
            if isempty(cond_sets)
                triples{end+1} = [i,j];
            end
            % TODO : Declare size in advance.
            for c = 1:size(cond_sets,1) 
                triples{end+1} = [i,j,cond_sets(c,:)]; 
            end
        end
    end
end
