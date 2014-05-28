classdef testundigraphmat2vec < TestCase
%TESTUNDIGRAPHMAT2VEC UNDIGRAPHMAT2VEC test case

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

    matrix
    vector

end

methods

function Obj = testundigraphmat2vec(name)

    Obj = Obj@TestCase(name);

    Obj.matrix = sparse([0 1 0 4; 1 0 3 0; 0 3 0 6; 4 0 6 0]);
    Obj.vector = sparse([ 1 0 4 3 0 6 ]');

end

function testdefault(Obj)

    clc;

    import org.mensxmachina.graph.undigraphmat2vec;

    vector = undigraphmat2vec(Obj.matrix);
    assertEqual(vector, Obj.vector);

end

end

end