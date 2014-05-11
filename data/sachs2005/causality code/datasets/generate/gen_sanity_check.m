X = [repmat( [ 0 0 1], 100, 1 ); repmat( [ 0 1 0], 100, 1 ); repmat( [ 1 0 0], 100, 1 ) ];
A = [repmat( [ 0 0 1], 100, 1 ); repmat( [ 0 1 0], 100, 1 ); repmat( [ 1 0 0], 100, 1 ) ];
targets = A;
X = canonizeLabels(X);

% we should put this in the meta-data so we don't get caught putting too
% low of an arity by chance
nStates = 2;

save sanity_check