function idx = subsample(n,k)

 p = randperm(n);
 idx = p(1:k);