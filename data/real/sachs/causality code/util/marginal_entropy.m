function H = marginal_entropy(X)
% calculates the sum of the marginal entropies of the empirical distribution of some data.

[n,d] = size(X);

H = 0;
for i = 1:d
    % search for how many copies there are of this data
    cur = X(:, i );
    counts = histc( cur, unique(cur) );

    p = counts ./ sum(counts);
    H = H - sum (p .* log( p ));
end


    
    