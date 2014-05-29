function tree = prim(G, weights, r)
%PRIM Prim's algorithm for graphs with multiple weights per edge.
%   MST = ORG.MENSXMACHINA.GRAPH.PRIM(G, WEIGHTS) returns a minimum
%   spanning tree for a connected undirected graph with multiple weights
%   per edge. G is a N-by-N sparse matrix representing an undirected graph.
%   Each nonzero element in the lower triangle of G denotes an edge in the
%   graph. WEIGHTS is an E-by-W numeric real matrix of W > 1 weights for
%   each of the E edges in G. The weights in each column of WEIGHTS are
%   ordered by linear index of the corresponding edge in G. The algorithm
%   first compares weights in the 1st column of WEIGHTS, and, if they are
%   equal, it compares weights in the 2nd column of WEIGHTS etc. MST is a
%   N-by-N sparse matrix representing the minimum spanning tree.
%
%   ORG.MENSXMACHINA.GRAPH.PRIM does not check if G is connected.
%
%   MST = ORG.MENSXMACHINA.GRAPH.PRIM(G, WEIGHTS, R) uses the node
%   specified by R as the root of MST. R is the linear index of a node in
%   G.
%
%   Example:
%       
%       import org.mensxmachina.graph.prim;
% 
%       % create graph
%
%       G = [...
%           0 0 0 0 0 0;
%           1 0 0 0 0 0;
%           0 1 0 0 0 0;
%           0 0 1 0 0 0;
%           1 0 0 1 0 0;
%           1 1 1 1 1 0;
%           ];
% 
%       G = sparse(G);
% 
%       % create node IDs
%       nodeIDs = {'A', 'B', 'C', 'D', 'E', 'F'};
%
%       % view graph
%       view(biograph(G, nodeIDs, 'ShowArrows', 'off'));
% 
%       % create weights
%       weights = [ ...
%           3   3
%           6   6
%           5   5
%           1   1
%           4 4.5
%           6   6
%           4   4
%           8   8
%           5   5
%           2   2
%       ];
%
%       % find minimum spanning tree
%       mst = prim(G, weights);
% 
%       % view tree 
%       view(biograph(mst, nodeIDs, 'ShowArrows', 'off'));
%
%
%   See also GRAPHMINSPANTREE.

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

% References
% [1] A. Levitin, Introduction to the Design and Analysis of  Algorithms,
%     Addison-Wesley, Boston

assert(issparse(G) && size(G, 1) == size(G, 2));
validateattributes(weights, {'numeric'}, {'real', '2d'});
assert(size(weights, 2) > 0 && size(weights, 1) == nnz(G));
   
if nargin < 3
    r = 1;
else
	validateattributes(r, {'numeric'}, {'integer', 'scalar', '>=', 1, '<=', size(G, 1)});
end

% [1], pp. 305-309

numNodes = size(G, 1); % get # of nodes in G

% initialize tree
tree = spalloc(numNodes, numNodes, nnz(G));

% initialize node labels
label = repmat(3, 1, numNodes); % assign all nodes to unseen

% initialize edge order
order = G;
order(find(G)) = 1:nnz(G);

% initialize nearest tree nodes and distances
nearestTreeNode = NaN(1, numNodes);
nearestTreeNodeDistance = Inf(size(weights, 2), numNodes);

% add R to the tree
[tree label nearestTreeNode, nearestTreeNodeDistance] = ...
    addustar(G, order, weights, label, nearestTreeNode, nearestTreeNodeDistance, tree, r, []);

for i = 1:(numNodes - 1)
    
    % find U*
    [u_star v_star] = findustar(label, weights, nearestTreeNode, nearestTreeNodeDistance);
    
    % add U* to the tree
    [tree label nearestTreeNode, nearestTreeNodeDistance] = ...
        addustar(G, order, weights, label, nearestTreeNode, nearestTreeNodeDistance, tree, u_star, v_star);
    
end

end

function [u_star v_star] = findustar(label, weights, nearestTreeNode, nearestTreeNodeDistance)

fringe = find(label == 2); % find fringe

u_star = fringe(1); % initialize U* to the first node in the fringe
v_star = nearestTreeNode(u_star); % initialize V* to the nearest tree node of U*

for u = fringe(2:end) % for each node U in the rest of the fringe
    for k = 1:size(weights, 2) % for each weights

        if nearestTreeNodeDistance(k, u) < nearestTreeNodeDistance(k, u_star)
            u_star = u;
            v_star = nearestTreeNode(u);
            break;
        elseif nearestTreeNodeDistance(k, u) > nearestTreeNodeDistance(k, u_star)
            break;            
        end

    end
end

end

function [tree label nearestTreeNode, nearestTreeNodeDistance] = ...
    addustar(G, order, weights, label, nearestTreeNode, nearestTreeNodeDistance, tree, u_star, v_star)

numWeights = size(weights, 2); % get # of weights

label(u_star) = 1; % add U* to tree

if ~isempty(v_star)
    tree(max(u_star, v_star), min(u_star, v_star)) = 1; % add (U*, V*) to the tree
end

% move unseen neighbors of U* to the fringe
label((G(u_star, :) | G(:, u_star)') & label == 3) = 2;

for u = find((G(u_star, :) | G(:, u_star)') & label == 2) % for each neighbor U of U* in the fringe

    for k = 1:numWeights % for each weights

        % get k-th weights of the (U, U*) edge 
        w_k_u_u_star = weights(order(max(u_star, u), min(u_star, u)), k);

        if w_k_u_u_star < nearestTreeNodeDistance(k, u)

            % set nearest tree node of U to U* 
            nearestTreeNode(u) = u_star;

            for l = 1:numWeights % for each weights

                % set nearest tree node k-th distance to the k-th weights of the (U, U*) edge 
                nearestTreeNodeDistance(l, u) = weights(order(max(u_star, u), min(u_star, u)), l);

            end

            break;

        elseif w_k_u_u_star > nearestTreeNodeDistance(k, u)
            break;            
        end

    end

end

end