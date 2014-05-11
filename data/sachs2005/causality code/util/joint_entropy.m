function H = joint_entropy(X)
% calculates the entropy ( in nats ) of the emperical distribution of some data.
% This version doesn't use a hash table, and runs in n^2 time

[n,d] = size(X);

H = 0;

for i = 1:n
    % search for how many copies there are of this data
    cur = X(i, : );
    copy = repmat( cur, n, 1 );
    diff = sum(abs(X - copy),2);
    count = sum( diff == 0 );
    
    % add the current entropy
    p = count / n;
    H = H - p * log( p ) / count;
end
    
    