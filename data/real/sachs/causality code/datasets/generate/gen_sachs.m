X = data';
targets = clamped';

A = zeros( size( X, 1 ), 9);

col = 1;
for i = 1:length(A) - 1
    A( i, col ) = 1;
    
    if sum(targets( i, :) ~= targets( i + 1, : )) > 0
        col = col + 1;
    end
end
A( end, col ) = 1;

% we should put this in the meta-data so we don't get caught putting too
% low of an arity by chance
nStates = 3;


save sachs