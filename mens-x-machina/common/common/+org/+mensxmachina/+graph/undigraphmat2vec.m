function vector = undigraphmat2vec(matrix)
%UNDIGRAPHMAT2VEC Convert undirected graph matrix to vector.
%   VECTOR = ORG.MENSXMACHINA.GRAPH.UNDIGRAPHMAT2VEC(MATRIX) converts
%   sparse matrix MATRIX representing a graph to numeric column vector
%   VECTOR representing a graph. MATRIX is an M-by-M sparse matrix. Each
%   nonzero element in the lower triangle of MATRIX denotes an edge in the
%   graph. VECTOR is a column vector of length L = M*(M - 1)/2 that
%   contains the elements of the lower triangle of MATRIX taken from MATRIX
%   in a columnwise manner.
%
%   Example:
%
%       import org.mensxmachina.graph.undigraphmat2vec;
%
%       matrix = [0 1 2 4; 1 0 3 5; 2 3 0 6; 4 5 6 0]
%       vector = undigraphmat2vec(matrix)
%
%   See also ORG.MENSXMACHINA.GRAPH.UNDIGRAPHVEC2MAT.

% Copyright 2010-2012 Mens X Machina
% 
% This file is part of Mens X Machina Common Toolbox.
% 
% Mens X Machina Common Toolbox is free software: you can redistribute it
% and/or modify it under the terms of the GNU General Public License
% alished by the Free Software Foundation, either version 3 of the License,
% or (at your option) any later version.
% 
% Mens X Machina Common Toolbox is distributed in the hope that it will be
% useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
% Public License for more details.
% 
% You should have received a copy of the GNU General Public License along
% with Mens X Machina Common Toolbox. If not, see
% <http://www.gnu.org/licenses/>.

assert(issparse(matrix) && size(matrix, 1) == size(matrix, 2));
    
matrix = tril(matrix, -1); % keep lower triangle

% find row and column indices of matrix nonzero elements 
[row col] = find(matrix);

% get # of variables
m = size(matrix, 1);

% get respective vector indices
ind = (col - 1).*(m - col/2) + row - col;

mchoose2 = (numel(matrix) - m)/2;

% create the sparse vector
vector = sparse(ind, 1, matrix(sub2ind([m m], row, col)), mchoose2, 1);
    
end