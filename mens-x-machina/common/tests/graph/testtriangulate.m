classdef testtriangulate < TestCase
%TESTTRIANGULATE TRIANGULATE test cases

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
% [1] C. Huang and A. Darwiche. Inference in belief networks: A procedural
%     guide. International Journal of Approximate Reasoning, 5(3):225-263,
%     1996.

properties

    G
    nodeIDs

end

methods

function Obj = testtriangulate(name)

    Obj = Obj@TestCase(name);
    
    % [1], p. 13

    Obj.G = [...
        0 0 0 0 0 0 0 0;
        1 0 0 0 0 0 0 0;
        1 0 0 0 0 0 0 0;
        0 1 0 0 0 0 0 0;
        0 0 1 1 0 0 0 0;
        0 0 0 1 1 0 0 0;
        0 0 1 0 1 0 0 0;
        0 0 0 0 1 0 1 0
        ];

    Obj.G = sparse(Obj.G);
    
    Obj.nodeIDs = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'};



end

function testdefault(Obj)

    clc;

    import org.mensxmachina.graph.triangulate;
    
    [G1 cliques1 cliqueWeights1] = triangulate(Obj.G, 2*ones(1, 8));
%     
%     G = G1;
%     cliques = cliques1;
%     cliqueWeights = cliqueWeights1;
%     
%     save('testtriangulate_testdefault', 'G', 'cliques', 'cliqueWeights');

    load('testtriangulate_testdefault', 'G', 'cliques', 'cliqueWeights');
    
%     % debug
%     
%     G = [...
%         0 0 0 0 0 0 0 0;
%         1 0 0 0 0 0 0 0;
%         1 0 0 0 0 0 0 0;
%         1 1 0 0 0 0 0 0;
%         1 0 1 1 0 0 0 0;
%         0 0 0 1 1 0 0 0;
%         0 0 1 0 1 0 0 0;
%         0 0 0 0 1 0 1 0
%         ];
% 
%     G = sparse(G);
% 
%     cliques = {[5 7 8], [3 5 7], [4 5 6], [1 3 5], [1 2 4], [1 4 5], [1 5], 1};
%     cliqueWeights = [8 8 8 8 8 8 4 2];
%     
%     assertEqual(cliques1, cliques(1:6));
%     assertEqual(cliqueWeights1, cliqueWeights(1:6));
    
    assertEqual(G1, G);
    assertEqual(cliques1, cliques);
    assertEqual(cliqueWeights1, cliqueWeights);

end

end

end