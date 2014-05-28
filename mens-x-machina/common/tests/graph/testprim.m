classdef testprim < TestCase
%TESTPRIM PRIM test cases

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
    weights
    tree
    multipleWeightsTree

end

methods

function Obj = testprim(name)

    Obj = Obj@TestCase(name);

    Obj.G = [...
        0 0 0 0 0 0;
        1 0 0 0 0 0;
        0 1 0 0 0 0;
        0 0 1 0 0 0;
        1 0 0 1 0 0;
        1 1 1 1 1 0;
        ];

    Obj.G = sparse(Obj.G);

    Obj.weights = [ ...
        3 3
        6 6
        5 5
        1 1
        4 4.5
        6 6
        4 4
        8 8
        5 5
        2 2
    ];

    Obj.tree = [...
        0 0 0 0 0 0;
        1 0 0 0 0 0;
        0 1 0 0 0 0;
        0 0 0 0 0 0;
        0 0 0 0 0 0;
        0 1 0 1 1 0
        ];

    Obj.tree = sparse(Obj.tree);

    Obj.multipleWeightsTree = [...
        0 0 0 0 0 0;
        1 0 0 0 0 0;
        0 1 0 0 0 0;
        0 0 0 0 0 0;
        0 0 0 0 0 0;
        0 0 1 1 1 0
        ];

    Obj.multipleWeightsTree = sparse(Obj.multipleWeightsTree);

end

function testsingleweight(Obj)

    import org.mensxmachina.graph.prim;

    clc;

    % test single weight
    tree = prim(Obj.G, Obj.weights(:, 1), 1);

    assertEqual(tree, Obj.tree);

end

function testmultipleweights(Obj)

    import org.mensxmachina.graph.prim;

    clc;

    % test multiple weights
    tree = prim(Obj.G, Obj.weights, 1);

    assertEqual(tree, Obj.multipleWeightsTree);   

end


end

end
