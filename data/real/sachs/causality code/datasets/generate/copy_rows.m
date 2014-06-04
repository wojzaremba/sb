function copied = copy_rows( X, num_copies )
% copies the rows in a matrix but leaves the order the same
% slow version

copied = [];

for i = 1:size( X, 1 )
    copied = [ copied; repmat( X( i, : ), num_copies, 1 ) ];
end