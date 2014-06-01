classdef testdummycttestrc < TestCase
%TESTDUMMYCXTESTRC DUMMYCXTESTRC test cases

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

properties(Access=private)
    
    Applier

    X
    Y
    Z
    S

end

methods

function Obj = testdummycttestrc(name)

    clc;
    
    import org.mensxmachina.stats.tests.ci.dummycitrcapplier;

    Obj = Obj@TestCase(name);
    
    % create applier
    Obj.Applier = dummycitrcapplier(4);

    Obj.X = 1;
    Obj.Y = 2;
    Obj.Z = [3 4];

    Obj.S = [1 2 3 4];
    
end

function testisreliablecit(Obj)

    tf = isreliablecit(Obj.Applier, [Obj.X, Obj.Y, Obj.Z]);
    assertTrue(tf);

end

function testworstmaxcondsetcard(Obj)

    maxk = Obj.Applier.worstmaxcondsetcard({}, {}, Obj.S);
    assertEqual(maxk, length(Obj.S) - 2);

    maxk = Obj.Applier.worstmaxcondsetcard({Obj.X}, {}, Obj.S);
    assertEqual(maxk, length(Obj.S) - 1);

    maxk = Obj.Applier.worstmaxcondsetcard({}, {Obj.Y}, Obj.S);
    assertEqual(maxk, length(Obj.S) - 1);

    maxk = Obj.Applier.worstmaxcondsetcard({Obj.X}, {Obj.Y}, Obj.S);
    assertEqual(maxk, length(Obj.S));

end

function testbestmaxcondsetcard(Obj)

    % copy-paste from testworstmaxcondsetcard, change worstmaxcondsetcard to bestmaxcondsetcard

    maxk = bestmaxcondsetcard(Obj.Applier, {}, {}, Obj.S);
    assertEqual(maxk, length(Obj.S) - 2);

    maxk = bestmaxcondsetcard(Obj.Applier, {Obj.X}, {}, Obj.S);
    assertEqual(maxk, length(Obj.S) - 1);

    maxk = bestmaxcondsetcard(Obj.Applier, {}, {Obj.Y}, Obj.S);
    assertEqual(maxk, length(Obj.S) - 1);

    maxk = bestmaxcondsetcard(Obj.Applier, {Obj.X}, {Obj.Y}, Obj.S);
    assertEqual(maxk, length(Obj.S));

end

end

end