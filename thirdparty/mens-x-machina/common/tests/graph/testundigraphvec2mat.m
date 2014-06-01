classdef testundigraphvec2mat < TestCase
%TESTUNDIGRAPHVEC2MAT UNDIGRAPHVEC2MAT test case

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

    vector
    matrix

end

methods

function Obj = testundigraphvec2mat(name)

    Obj = Obj@TestCase(name);

    Obj.vector = sparse([1 0 4 3 0 6]');
    Obj.matrix = sparse([0 0 0 0; 1 0 0 0; 0 3 0 0; 4 0 6 0]);

end

function testdefault(Obj)

    import org.mensxmachina.graph.undigraphvec2mat;

    % test sparse vector
    matrix = undigraphvec2mat(Obj.vector);
    assertEqual(matrix, Obj.matrix);

end

end

end