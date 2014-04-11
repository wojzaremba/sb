function s = normalize_discrete(s)

s = s - repmat(mean(s,2),1,size(s,2));
s = s ./ repmat(std(s,[],2),1,size(s,2));