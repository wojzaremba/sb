function tf = isdsep(G, c, b, a)
%ISDSEP Detect nodes d-separated from a given set of nodes by another.
%   TF = ORG.MENSXMACHINA.GRAPH.ISDSEP(G, C, B, A) detects nodes of a set C
%   of that are d-separated from a set of nodes B given another set of
%   nodes A in directed acyclic graph () G. G is a M-by-M sparse matrix.
%   Each nonzero element in G denotes an edge in the graph. C is a vector
%   of node linear indices in G. B and A are disjoint vectors of node
%   linear indices in G. TF is 1-by-M logical vector containing logical 1
%   (true) where the nodes in C are d-separated from B given A and logical
%   0 (false) elsewhere.
%
%   ORG.MENSXMACHINA.GRAPH.ISDSEP does not check if G is acyclic.
%
%   Example:
%
%       import org.mensxmachina.graph.isdsep;
%
%       % create a DAG
%       G = sparse([1 1 2 3], [2 3 4 4], ones(1, 4), 4, 4);
%
%       % view DAG
%       view(biograph(G));
%
%       % check a d-separation
%       isdsep(G, 1, 4, [2 3])

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
% [1] Richard E. Neapolitan. Learning Bayesian Networks. Prentice Hall,
%     April 2003.

import org.mensxmachina.graph.ancestors;

assert(issparse(G) && size(G, 1) == size(G, 2));
validateattributes(c, {'numeric'}, {'vector', 'integer', '>=', 1, '<=', size(G, 2)});
validateattributes(b, {'numeric'}, {'vector', 'integer', '>=', 1, '<=', size(G, 2)});
validateattributes(a, {'numeric'}, {'vector', 'integer', '>=', 1, '<=', size(G, 2)});

% check consistency
assert(isempty(intersect(b, a)));

% create G', the graph with links in G going in both directions
G_prime = G + G';

% get number of nodes
m = size(G, 1);

% create graph with G' labels
G_prime_label = spalloc(m, m, nnz(G_prime));

% detect nodes in A ("in[V]")
inA = false(1, m);
inA(a) = true;

% detect nodes that are in A or have a descendent in A ("descendent[V]")
isOrHasDescendentInA = false(1, m);
isOrHasDescendentInA(a) = true;
isOrHasDescendentInA(cell2mat(arrayfun(@(x) ancestors(G, x), a, 'UniformOutput', false))) = true;

% initialize OPEN:
% nodes in C remaining to be found d-separated or not with B given A;
% empty c denotes all nodes

if ~isempty(c) % open nodes mode
    open = c; % set to node in C
end

tf = true(1, m); % initially set all nodes as d-separated from B given A
tf(b) = false; % set all nodes in B as not d-separated from B given A

if ~isempty(c) % specific nodes mode
    
    open = setdiff(open, b); % remove B from OPEN
    
    if isempty(open) % no more open nodes
        
        tf = tf(c); % limit output to nodes in C
        return;
        
    end
    
end

tf(a) = false; % set all nodes in A as not d-separated from B given A

if ~isempty(c) % specific nodes mode
    
    open = setdiff(open, a); % remove A from OPEN
    
    if isempty(open) % no more open nodes
        
        tf = tf(c); % limit output to nodes in C
        return;
        
    end
    
end

% % debug
% bg = biograph(G, arrayfun(@(i) num2str(i), 1:m, 'UniformOutput', false), 'ShowWeights', 'on');
% set(bg.edges, 'Weight', 0);

for x = b % for each node X in B

    % find children of X in G' ("V")
    v = find(G_prime(x, :)); 

    % set the children as not d-separated from B given A (i.e add V to R)
    tf(v) = false;

    if ~isempty(c) % specific nodes mode

        open = setdiff(open, v); % remove A from OPEN

        if isempty(open) % no more open nodes
            
            tf = tf(c); % limit output to nodes in C
            return;
            
        end

    end

    % label the corresponding edges with 1
    G_prime_label(x, v) = 1;
    
%     % debug
%     for i = v
%         if G(x, i)
%             edge = getedgesbynodeid(bg, num2str(x), num2str(i));
%         else
%             edge = getedgesbynodeid(bg, num2str(i), num2str(x));
%         end
%         set(edge, 'Weight', 1);
%     end
    
end

i = 1; % set last label used to 1

found = true; % whether we found all legal paths from B to C

while found % while we have not found all legal paths from B to C

    found = false;
    
    % find i-labelled edges
    [iLabelledEdgeParent iLabelledEdgeChild] = find(G_prime_label == i);
    
    for k=1:length(iLabelledEdgeParent) % for each V such that U->V is labelled i
        
        u = iLabelledEdgeParent(k);
        v = iLabelledEdgeChild(k);

        % initialize W: reachable children of B
        w = [];
        
        % find parents and children of V in G
        parentsInG_v = find(G(:, v))';
        childrenInG_v = find(G(v, :));
        
        if ismember(u, parentsInG_v) % U->V in G
            
            if isOrHasDescendentInA(v) % (A) <- ... <- V <- W
                w = parentsInG_v; % U->V<-W (head-to-head)
            end

            if ~inA(v)
                w = [w childrenInG_v]; % U->V->W (head-to-tail) DAMMIT!
            end

        else % U<-V in G

            if ~inA(v)
                w = [parentsInG_v childrenInG_v]; % U<-V->W (tail-to-tail) and U<-V<-W (tail-to-head)
            end

        end
        
        % keep W that are ends of unlabeled edges V->W
        w = w(~G_prime_label(v, w));
        
        if ~isempty(w)
            
            % set them as not d-separated from B given A (i.e. add W to Rs)
            tf(w) = false;

            if ~isempty(c) % specific nodes mode
                
                open = setdiff(open, w); % remove W from OPEN

                if isempty(open) % no more open nodes
                    
                    tf = tf(c); % limit output to nodes in C             
                    %bg.view(); % debug
                    %assert(tf == dsep(c, b, a, G)) % debug with BNT
                    return;
                    
                end

            end
            
            % label the corresponding edges with i + 1
            G_prime_label(v, w) = i + 1;
            
%             % debug
%             for j = w
%                 if G(v, j)
%                     edge = getedgesbynodeid(bg, num2str(v), num2str(j));
%                 else
%                     edge = getedgesbynodeid(bg, num2str(j), num2str(v));
%                 end
%                 set(edge, 'Weight', i + 1);
%             end
            
            % set the found flag
            found = true;
            
        end
        
    end   
    
    % i + 1 is the new i
    i = i + 1;
    
end

%bg.view(); % debug

if ~isempty(c)
    
    tf = tf(c);
    %assert(tf == dsep(c, b, a, G)) % debug with BNT

end

end