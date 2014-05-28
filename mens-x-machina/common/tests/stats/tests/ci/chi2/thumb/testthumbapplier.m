classdef testthumbapplier < TestCase
%TESTTHUMBCITRC THUMBCITRC test cases

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

properties(Access = private)
    
    TestRCApplier

end

methods

function Obj = testthumbapplier(name)

    clc;
    
    import org.mensxmachina.stats.tests.ci.chi2.thumb.thumbapplier;

    Obj = Obj@TestCase(name);
    
    sample = randi(2, 10, 5);
    varNValues = 2*ones(1, 5);
    
    Obj.TestRCApplier = thumbapplier(sample, varNValues);

end

function testisreliable(Obj)

    isreliablecit(Obj.TestRCApplier, 1, 2, [3 4]);
    
end

end

end
