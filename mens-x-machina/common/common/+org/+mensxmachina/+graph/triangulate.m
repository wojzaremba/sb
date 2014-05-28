function [G clique cliqueWeight] = triangulate(G, nodeWeights)
%TRIANGULATE Triangulate undirected graph.
%   G = ORG.MENSXMACHINA.GRAPH.TRIANGULATE(G, NODEWEIGHTS) triangulates
%   undirected graph G. G is a M-by-M sparse matrix. Each nonzero element
%   in the lower triangle of G denotes an edge in the graph. NODEWEIGHTS is
%   an 1-by-M numeric real array with nonnegative elements. Each element of
%   W is the weight of the corresponding node in G. Output G is a M-by-M
%   sparse matrix representing the triangulated graph.
%
%   [G CLIQUE] = ORG.MENSXMACHINA.GRAPH.TRIANGULATE(G, NODEWEIGHTS) also
%   returns the cliques in output G. CLIQUE is an 1-by-N cell array
%   containing linear indices of nodes in G.
%
%   [G CLIQUE CLIQUEWEIGHTS] = ORG.MENSXMACHINA.GRAPH.TRIANGULATE(G,
%   NODEWEIGHTS) also returns the weights of the clusters in output G.
%   CLIQUEWEIGHTS is an 1-by-N vector.
%
%   Example:
% 
%       import org.mensxmachina.graph.triangulate;
% 
%       % create graph
%       G = [...
%               0 0 0 0 0 0 0 0;
%               1 0 0 0 0 0 0 0;
%               1 0 0 0 0 0 0 0;
%               1 1 0 0 0 0 0 0;
%               1 0 1 1 0 0 0 0;
%               0 0 0 1 1 0 0 0;
%               0 0 1 0 1 0 0 0;
%               0 0 0 0 1 0 1 0
%           ];
% 
%       G = sparse(G);
% 
%       % create node IDs
%       nodeIDs = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'};
% 
%       % view graph
%       view(biograph(G, nodeIDs, 'ShowArrows', 'off'));   
% 
%       % triangulate graph
%       G = triangulate(G, 2*ones(1, 8));
% 
%       % view graph
%       view(biograph(G, nodeIDs, 'ShowArrows', 'off'));  

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
%     guide. International Journal of Approximate Reasoning, 5(3):225-263,
%     1996.

import org.mensxmachina.graph.*;

% parse input
assert(issparse(G) && size(G, 1) == size(G, 2));
validateattributes(nodeWeights, {'numeric'}, {'real', 'size', [1 size(G, 1)]}, 'nonnegative');

numNodes = size(G, 1); % get # of nodes in G

G_prime = G; % copy G
flag = true(1, numNodes); % initialize retained node flags

cluster_node = cell(1, numNodes); % initialize cluster / node
numEdgesAdded_node = zeros(1, numNodes); % initialize # of edges added / node
weight_cluster_node = zeros(1, numNodes); % initialize cluster clusterWeight / node

cluster = cell(1, numNodes); % initialize clusters
clusterWeight = zeros(1, numNodes); % initialize cluster weights

clique = {}; % initialize cliques
cliqueWeight = []; % initialize clique weights

init();

i = 0;

while any(flag) % while there are nodes in G'
    
    i = i + 1;
    
    % select a node u* from G'
    peek();
    
    cluster{i} = cluster_node{u_star};
    clusterWeight(i) = weight_cluster_node(u_star);
    
    if ~any(cellfun(@(jClique) all(ismember(cluster{i}, jClique)), clique))

        % cluster i is not a subset of any previously saved cluster

        clique = [clique cluster{i}]; % add to cliques
        cliqueWeight = [cliqueWeight clusterWeight(i)]; % add to clique weights

    end
    
    update();
    
end

% nested functions

function peek()

% % debug
% elim = [8 7 6 3 2 4 5 1];
% s = 8 - sum(flag) + 1;
% u_star = elim(s);
% return;

nodes_G_prime = find(flag);

u_star = nodes_G_prime(1);

for u = nodes_G_prime(2:end) % for each node u among the rest nodes in G'

    if numEdgesAdded_node(u) < numEdgesAdded_node(u_star) ...
            || (numEdgesAdded_node(u) == numEdgesAdded_node(u_star) && weight_cluster_node(u) < weight_cluster_node(u_star))

        u_star = u;

    end        

end

end

function init()

for u = 1:numNodes

    cluster_node{u} = sort([u find(G_prime(u, :) | G_prime(:, u)')]); % find cluster

    G_prime_new = G_prime; % copy G'
    G_prime_new(cluster_node{u}, cluster_node{u}) = 1; % connect cluster nodes to each other
    G_prime_new = tril(G_prime_new, -1); % keep only lower triangle

    numEdges = nnz(G_prime); % get # of edges in G'
    numEdges_new = nnz(G_prime_new); % get # of edges in new G'

    numEdgesAdded_node(u) = numEdges_new - numEdges; % get difference
    weight_cluster_node(u) = prod(nodeWeights(cluster_node{u})); % calculate cluster clusterWeight

end

end

function update()

G_prime_temp = G_prime; % copy G'
G_prime_temp(cluster_node{u_star}, cluster_node{u_star}) = 1; % connect cluster nodes to each other
G_prime_temp = tril(G_prime_temp, -1); % keep only lower triangle 

% get edges in G' not in G
edge_added = find(G_prime_temp ~= G_prime);

G_prime = G_prime_temp;

% add edges to G
G(edge_added) = 1;

% remove node u_star from consideration
G_prime(u_star, :) = 0; 
G_prime(:, u_star) = 0;  
flag(u_star) = false; 

for u = cluster_node{u_star}

    if u == u_star
        continue;
    end

    cluster_node{u} = sort([u find(G_prime(u, :) | G_prime(:, u)')]); % find cluster

    G_prime_new = G_prime; % copy G'
    G_prime_new(cluster_node{u}, cluster_node{u}) = 1; % connect cluster nodes to each other
    G_prime_new = tril(G_prime_new, -1); % keep only lower triangle

    numEdges = nnz(G_prime); % get # of edges in G'
    numEdges_new = nnz(G_prime_new); % get # of edges in new G'

    numEdgesAdded_node(u) = numEdges_new - numEdges; % get difference
    weight_cluster_node(u) = prod(nodeWeights(cluster_node{u})); % calculate cluster nodeWeights

end

end

end