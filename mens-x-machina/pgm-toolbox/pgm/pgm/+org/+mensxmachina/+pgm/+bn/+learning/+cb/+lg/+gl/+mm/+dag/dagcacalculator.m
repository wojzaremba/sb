classdef(Sealed) dagcacalculator < org.mensxmachina.pgm.bn.learning.cb.lg.gl.mm.cacalculator
%DAGCACALCULATOR DAG-based conditional-association calculator.
%   ORG.MENSXMACHINA.PGM.BN.LEARNING.CB.LG.GL.MM.DAG.DAGCACALCULATOR is the
%   class of DAG-based conditional-association calculators. A DAG-based
%   conditional-association calculator considers both primary and secondary
%   association to be 0 if the corresponding d-separation holds and Inf
%   otherwise.
%
%   See also ORG.MENSXMACHINA.PGM.BN.LEARNING.CB.LG.GL.MM.CACALCULATOR,
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

function Obj = dagcacalculator(dag)
%DAGCACALCULATOR Create DAG-based conditional-association calculator.
%   OBJ =
%   ORG.MENSXMACHINA.PGM.BN.LEARNING.CB.LG.GL.MM.DAG.DAGCACALCULATOR(G)
%   creates a DAG-based conditional-association calculator with DAG G. G is
%   an M-by-M sparse matrix. Each nonzero element in G denotes an edge in
%   the graph.

	assert(issparse(dag) && size(dag, 1) == size(dag, 2));
	assert(graphisdag(dag));

    Obj.nVars = size(dag, 2);
    Obj.dag = dag;

end

% abstract method implementations

function [ca ca2] = ca(Obj, i, j, k)
    
    if Obj.dag(j, i) || Obj.dag(i, j)

        % adj(Y,X) <=> ~dsep(Y,X|Z) given any Z <=>
        % ~CI(Y,X|Z) given any Z (under faithfulness) <=>
        % CA =/= 0
        isDSep = false;

    else

        % find if node Y is d-separated in G with node X given node(s) Z
        isDSep = org.mensxmachina.graph.isdsep(Obj.dag, i, j, k);

    end
        
    if isDSep % dsep(Y,X|Z) <=> CI(Y,X|Z) (under faithfulness) <=> CA(Y,X|Z) == 0

        ca = 0;
        ca2 = 0;

    else % ~dsep(Y,X|Z) <=> ~CI(Y,X|Z) (under faithfulness) <=> CA(Y,X|Z) ~= 0

        ca = Inf;
        ca2 = Inf;
        
    end

end

end

end