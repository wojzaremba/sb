classdef(Sealed) dagdsepdeterminer < org.mensxmachina.pgm.bn.learning.cb.dsepdeterminer
%DAGDSEPDETERMINER DAG-based d-separation determiner.
%   ORG.MENSXMACHINA.PGM.BN.LEARNING.CB.DAG.DAGDSEPDETERMINER is the class
%   of DAG-based d-separation determiners. A DAG-based d-separation
%   determiner determines d-separations using the actual DAG.
%
%   See also ORG.MENSXMACHINA.PGM.BN.LEARNING.CB.DSEPDETERMINER,
%   ORG.MENSXMACHINA.GRAPH.ISDSEP.

% Copyright 2010-2012 Mens X Machina
% 
% This file is part of Mens X Machina Probabilistic Graphical Model
% Toolbox.
% 
% Mens X Machina Probabilistic Graphical Model Toolbox is free software:
% you can redistribute it and/or modify it under the terms of the GNU
% General Public License alished by the Free Software Foundation, either
% version 3 of the License, or (at your option) any later version.
% 
% Mens X Machina Probabilistic Graphical Model Toolbox is distributed in
% the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
% the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
% PURPOSE. See the GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License along
% with Mens X Machina Probabilistic Graphical Model Toolbox. If not, see
% <http://www.gnu.org/licenses/>.

properties(SetAccess = immutable)
    
nVars % number of variables -- a numeric nonnegative integer
    
dag % DAG -- an M-by-M sparse matrix representing a DAG
    
end

methods

% constructor

function Obj = dagdsepdeterminer(dag)
%DAGDSEPDETERMINER Create DAG-based d-separation determiner.
%   OBJ = ORG.MENSXMACHINA.PGM.BN.LEARNING.CB.DAG.DAGDSEPDETERMINER(G)
%   creates a DAG-based d-separation determiner with DAG G. G is an M-by-M
%   sparse matrix. Each nonzero element in G denotes an edge in the graph.
    
    % parse input
	assert(issparse(dag) && size(dag, 1) == size(dag, 2));
	assert(graphisdag(dag));
    
    % set properties
    Obj.nVars = size(dag, 2);
    Obj.dag = dag;

end

% abstract method implementations

function tf = isdsep(Obj, i, j, k)
    
    import org.mensxmachina.graph.isdsep;
    
    % (no validation)
    
    if Obj.dag(j, i) || Obj.dag(i, j)

        % adj(X,Y) <=> ~dsep(X,Y|Z) given any Z
        tf = false;

    else

        % find if node X is d-separated in G with node Y given node(s) Z
        tf = isdsep(Obj.dag, i, j, k);

    end

end

function msc = maxsepsetcard(~, i, j, k)
    
    % (no validation)
    
    % dummy
    msc = length(k) - (2 - length(i) - length(j));
    
end

end

end