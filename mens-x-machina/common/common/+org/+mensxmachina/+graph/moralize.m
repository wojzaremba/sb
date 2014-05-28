function M = moralize(G)
%MORALIZE Moralize graph.
%   M = ORG.MENSXMACHINA.GRAPH.MORALIZE(G) returns a moral graph M from
%   directed acyclic graph (DAG) G. G is an N-by-N sparse matrix that
%   represents a directed acyclic graph. Nonzero entries in G indicate the
%   presence of an edge. M is a N-by-N sparse matrix whose lower triangle
%   represents the moralized graph.
%
%   ORG.MENSXMACHINA.GRAPH.MORALIZE does not check if G is acyclic.
%
%   Examples:
%
%       import org.mensxmachina.graph.moralize;
% 
%       % create a DAG
%     
%       G = [...
%           0 1 1 0 0 0 0 0;
%           0 0 0 1 0 0 0 0;
%           0 0 0 0 1 0 1 0;
%           0 0 0 0 0 1 0 0;
%           0 0 0 0 0 1 0 1;
%           0 0 0 0 0 0 0 0;
%           0 0 0 0 0 0 0 1;
%           0 0 0 0 0 0 0 0;
%           ];
%     
%       G = sparse(G);
%     
%       % create node IDs
%       nodeIDs = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'};
%     
%       % view DAG
%       view(biograph(G, nodeIDs));
%     
%       % moralize DAG
%       M = moralize(G);
%     
%       % view moral graph
%       view(biograph(M, nodeIDs, 'ShowArrows', 'off'));

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

% References:
% [1] C. Huang and A. Darwiche. Inference in belief networks: A procedural
%     guide. International Journal of Approximate Reasoning, 15(3):225-263,
%     1996.

% parse input
assert(issparse(G) && size(G, 1) == size(G, 2));

M = tril(G + G', -1);

numNodes = size(G, 1);

for i = 1:numNodes % for each node

    pa_i = find(G(:, i)'); % find its parents
        
    % connect its parents to each other in M
    M(pa_i, pa_i) = 1;
    
end

M = tril(M, -1); % keep lower triangle only

end