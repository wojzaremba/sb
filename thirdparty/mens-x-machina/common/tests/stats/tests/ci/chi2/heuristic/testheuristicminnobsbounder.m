classdef testheuristicminnobsbounder < TestCase
%TESHEURISTICCITRC HEURISTICCITRC test cases

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

properties(GetAccess = private, SetAccess = immutable)
    
    minSampleSizeCalculator

end

methods

function Obj = testheuristicminnobsbounder(name)

    clc;

    import org.mensxmachina.stats.tests.ci.chi2.gtestpvalueestimator;
    import org.mensxmachina.stats.tests.ci.chi2.heuristic.heuristicminnobsbounder;

    Obj = Obj@TestCase(name);
    
    varNLevels = [2 3 4 5];
    
    Obj.minSampleSizeCalculator = heuristicminnobsbounder(varNLevels);

end

function testworstminnobs(Obj)
    
    worstminnobs(Obj.minSampleSizeCalculator, zeros(1, 0), zeros(1, 0), [1 2 3 4], 2);

end

end

end