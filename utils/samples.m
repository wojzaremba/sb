function s = samples(bnet,N)
K = size(bnet.dag, 1);
s = zeros(K,N);
for i = 1 : size(s, 2)   
    tmp = sample_bnet(bnet);    
    for j = 1:length(tmp)
        s(j, i) = tmp{j};
    end    
end
end