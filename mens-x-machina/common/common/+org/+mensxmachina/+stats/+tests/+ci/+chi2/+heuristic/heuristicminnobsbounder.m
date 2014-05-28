classdef(Sealed) heuristicminnobsbounder < org.mensxmachina.stats.tests.ci.citrcminnobsbounder
%HEURISTICMINNOBSBOUNDER Heuristic-power-rule minimal-sample-size bounder.
%   ORG.MENSXMACHINA.STATS.TESTS.CI.HEURISTIC.HEURISTICMINNOBSBOUNDER is
%   the class of Heuristic-power-rule minimal-sample-size bounders.

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
% [1] Aliferis, C. F., Statnikov, A., Tsamardinos, I., Mani, S., and
%     Koutsoukos, X. D. 2010. Local Causal and Markov Blanket Induction for
%     Causal Discovery and Feature Selection for Classification Part I:
%     Algorithms and Empirical Evaluation. J. Mach. Learn. Res. 11 (Mar.
%     2010), 171-234.

properties(SetAccess = immutable)
    
    nVars % number of variables -- a numeric nonnegative integer
    
end

properties(GetAccess = private, SetAccess = immutable)
    
    varNLevels % variable numbers of values -- an 1-by-N numeric vector of positive integers 
    
    hps % h-ps -- a numeric nonnegative integer

end

methods

% constructor

function Obj = heuristicminnobsbounder(varNLevels, hps)
%HEURISTICMINNOBSBOUNDER Create heuristic-power-rule minimal-sample-size bounder.
%   OBJ =
%   ORG.MENSXMACHINA.STATS.TESTS.CI.HEURISTIC.HEURISTICMINNOBSBOUNDER(VARNVALUES)
%   creates a heuristic-power-rule minimal-sample-size bounder with
%   variable numbers of values VARNVALUES and h-ps 5. VARNVALUES is an
%   1-by-N numeric vector of positive integers, where N is the number of
%   variables. Each element of VARNVALUES is the number of values of the
%   corresponding variable.
%
%   OBJ =
%   ORG.MENSXMACHINA.STATS.TESTS.CI.HEURISTIC.HEURISTICMINNOBSBOUNDER(VARNVALUES,
%   HPS) sets h-ps to HPS. HPS is a numeric nonnegative integer.

    % parse input
    
    validateattributes(varNLevels, {'numeric'}, {'row', 'positive', 'integer'});
    
    if nargin < 3
        hps = 5;
    else
        validateattributes(hps, {'numeric'}, {'scalar', 'nonnegative', 'integer'});
    end
    
    % set properties
    Obj.nVars = length(varNLevels);
    Obj.varNLevels = varNLevels;
    Obj.hps = hps;
    
end

% abstract method implementations

function wmn = worstminnobs(Obj, i, j, ind, condsetCard)
    
    parseminnobsinput(Obj, i, j, ind, condsetCard);
    
    wmn = minsamplesize(Obj, i, j, ind, 'descend', condsetCard);
    
end

function bmn = bestminnobs(Obj, i, j, ind, condsetCard)
    
    parseminnobsinput(Obj, i, j, ind, condsetCard);
    
    bmn = minsamplesize(Obj, i, j, ind, 'ascend', condsetCard);
    
end

end

methods(Access = private)
    
function minsamplesize = minsamplesize(Obj, i, j, ind, sNValuesSortMode, condsetCard)
    
    % get number of levels for each test variable
    xNLevels = Obj.varNLevels(i);
    yNLevels = Obj.varNLevels(j);
    sNLevels = Obj.varNLevels(ind);
    
    nLevels = [xNLevels yNLevels sort(sNLevels, sNValuesSortMode)];

    % N/PROD(NUMLEVELS(1:(2 + K))) >= HPS solved for N
    minsamplesize = ceil(Obj.hps*prod(nLevels(1:(2 + condsetCard))));

end    

end

end