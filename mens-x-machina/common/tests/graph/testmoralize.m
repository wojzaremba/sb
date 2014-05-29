classdef testmoralize < TestCase
%TESTMORALIZE MORALIZE test cases

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

properties

    G
    M

end

methods

function Obj = testmoralize(name)

    Obj = Obj@TestCase(name);

    Obj.G = [...
        0 1 1 0 0 0 0 0;
        0 0 0 1 0 0 0 0;
        0 0 0 0 1 0 1 0;
        0 0 0 0 0 1 0 0;
        0 0 0 0 0 1 0 1;
        0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 1;
        0 0 0 0 0 0 0 0;
        ];

    Obj.G = sparse(Obj.G);

    Obj.M = [...
        0 0 0 0 0 0 0 0;
        1 0 0 0 0 0 0 0;
        1 0 0 0 0 0 0 0;
        0 1 0 0 0 0 0 0;
        0 0 1 1 0 0 0 0;
        0 0 0 1 1 0 0 0;
        0 0 1 0 1 0 0 0;
        0 0 0 0 1 0 1 0
        ];

    Obj.M = sparse(Obj.M);

end

function testdefault(Obj)

    import org.mensxmachina.graph.moralize;
    
    M = moralize(Obj.G);
    assertEqual(M, Obj.M);

end

end

end
