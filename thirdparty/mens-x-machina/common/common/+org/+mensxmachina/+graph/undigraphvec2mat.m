function matrix = undigraphvec2mat(vector)
%UNDIGRAPHVEC2MAT Convert graph matrix from vector to matrix form.
%   MATRIX = ORG.MENSXMACHINA.GRAPH.UNDIGRAPHVEC2MAT(VECTOR) converts
%   sparse M-by-1 vector VECTOR to N-by-N sparse matrix MATRIX representing
%   an undirected graph, where N = (1 + SQRT(1 + 8*M))/2 and M is such that
%   N is a positive integer. The lower triangle of MATRIX consists of the
%   elements of VECTOR taken in a columnwise manner.
%
%   Example:
%
%       import org.mensxmachina.graph.undigraphvec2mat;
%
%       vector = [1 2 4 3 5 6]'
%       matrix = undigraphvec2mat(vector)
%
%   See also ORG.MENSXMACHINA.GRAPH.UNDIGRAPHMAT2VEC.

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

assert(issparse(vector) && ndims(vector) == 2 && size(vector, 2) == 1);

% calculate # of variables
m = (1 + sqrt(1 + 8*length(vector)))/2;

assert(round(m) == m);

% find vector indices of nonzero vector elements
ind = find(vector);

% find row and column indices of the correspoding elements in the lower
% triangular
[row col] = undigraphvecind2matsub(length(vector), ind);

% create matrix with the vector elements
matrix = sparse(row, col, vector(ind), m, m);
    
end

function [row col] = undigraphvecind2matsub(n, ind)
%UNDIGRAPHVECIND2MATSUB Convert skeleton vector indices to matrix subscripts.
%   [ROW COL] = ORG.MENSXMACHINA.GRAPH.UNDIGRAPHMATSUB2VECIND(N, IND)
%   converts the linear indices IND in the vector representation of length
%   N of an undirected graph to row and column indices ROW and COL in the
%   lower triangle part of the matrix representation of the graph.

ip = inputParser;

ip.addRequired('n', @(a) validateattributes(a, {'numeric'}, {'integer', 'scalar', '>=', 2}));
ip.addRequired('ind', @(a) validateattributes(a, {'numeric'}, {'vector', 'integer', '>=', 1, '<=', n}));

ip.parse(n, ind);

% calculate # of variables
m = (1 + sqrt(1 + 8*n))/2;

assert(round(m) == m);

% initialize row and columns indices
row = zeros(size(ind));
col = zeros(size(ind));

j = 1; % current column of the lower triangle

triunumel_prev = 0; % # of elements in the lower triangle, up to the previous column
triunumel = m - 1; % # of elements in the lower triangle, up to this column

% sort indices
ind = sort(ind);

for k = 1:length(ind) % for each sorted vector index

    if isnan(ind(k))
        
        row(k) = NaN;
        col(k) = NaN;
        
        continue;
        
    end
    
    % vector index k of the element is the number of elements in the
    % lower triangle, taken in a columnwise manner, up to the element

    % find j

    for j=j:m-1 % for each lower triangle column except the last one

        if ind(k) > triunumel_prev && ind(k) <= triunumel % element belongs in this column

            % calculate i
            i = ind(k) - (j - 1)*(m - j/2) + j;

            row(k) = i;
            col(k) = j;

            break;

        end

        triunumel_prev = triunumel;
        triunumel = triunumel_prev + (m - j - 1);

    end

end
    
end