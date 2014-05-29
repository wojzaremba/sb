classdef(Sealed) dagcitpvalueestimator < org.mensxmachina.stats.tests.ci.citpvalueestimator
%DAGCITPVALUEESTIMATOR DAG-based conditional-independence-p-value estimator.
%   ORG.MENSXMACHINA.PGM.BN.LEARNING.CB.CIT.DAG.DAGCITPVALUEESTIMATOR is
%   the class of DAG-based conditional-independence-p-value estimators. A
%   DAG-based conditional-independence-p-value estimator estimates the
%   p-value of a hypothesis test of conditional independence by checking
%   the corresponding d-separation in a DAG. If the d-separation holds, the
%   p-value and the statistic of the test is 0 and Inf, respectivelly.
%   Otherwise, it is 1 and 0, respectivelly.

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

function Obj = dagcitpvalueestimator(dag)
%DAGCITPVALUEESTIMATOR Create DAG-based conditional-independence-p-value estimator.
%   OBJ =
%   ORG.MENSXMACHINA.PGM.BN.LEARNING.CB.CIT.DAG.DAGCITPVALUEESTIMATOR(G)
%   creates a DAG-based conditional-independence-p-value estimator with DAG
%   G. G is an M-by-M sparse matrix. Each nonzero element in G denotes an
%   edge in the graph.
    
    assert(issparse(dag) && size(dag, 1) == size(dag, 2));
	assert(graphisdag(dag));

    % set properties
    Obj.nVars = size(dag, 2);
    Obj.dag = dag;

end

% abstract method implementations

function [p stat] = citpvalue(Obj, i, j, k)
    
    if Obj.dag(j, i) || Obj.dag(i, j)

        % adj(X,Y) <=>
        % ~dsep(X,Y|Z) given any Z <=> ~ind(X,Y|Z) given any Z (under faithfulness)
        h = true;

    else

        % find if node X is d-separated in G with node Y given node(s)
        % Z; the alternative hypothesis is true iff X is not d-separated (under faithfulness)
        h = ~org.mensxmachina.graph.isdsep(Obj.dag, i, j, k);

    end

    if h
        p = 0;
        stat = Inf;
    else
        p = 1;
        stat = 0;
    end

end

end

end