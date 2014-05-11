% generate mini-sachs
%
% this dataset is only for a quick demo.  It has fewer rows and columns
% than the full sachs dataset.


load sachs

emptyrows = find( sum( targets, 2 ) == 0 );
emptycols = find( sum( targets, 1 ) == 0 );

targets( emptyrows, :) = [];
targets( :, emptycols ) = [];
X( emptyrows, :) = [];
X( :, emptycols ) = [];

A( emptyrows, :) = [];
emptyAcols = find( sum( A, 1 ) == 0 );
A( :, emptyAcols ) = [];

save('mini_sachs', 'X', 'A', 'targets', 'nStates');