function s = samples(bnet,N)

K = size(bnet.dag, 1);
s = zeros(K,N);
p = zeros(K,N);
for i = 1 : N  
    tmp = sample_bnet(bnet);    
    for j = 1:length(tmp)
        s(j, i) = tmp{j};
    end
end
end