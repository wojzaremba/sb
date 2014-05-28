classdef testancestormatrix < TestCase
%TESTANCESTORMATRIX ANCESTORMATRIX test cases

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
    am

end

methods

function Obj = testancestormatrix(name)

    Obj = Obj@TestCase(name);

    Obj.G = sparse(4, 4);

    Obj.G(1, 2) = 1;
    Obj.G(1, 3) = 1;
    Obj.G(2, 4) = 1;
    Obj.G(3, 4) = 1;
    
    Obj.G = logical(Obj.G);

    Obj.am = sparse(4, 4);

    Obj.am(1, 2) = 1;
    Obj.am(1, 3) = 1;
    Obj.am(1, 4) = 1;
    Obj.am(2, 4) = 1;
    Obj.am(3, 4) = 1;
    
    Obj.am = logical(Obj.am);

end

function testg(Obj)

    clc;

    % test non-sparse
    assertExceptionThrown(@setnonsparse, 'MATLAB:assert:failed');
    function setnonsparse()
        import org.mensxmachina.graph.ancestormatrix;
        ancestormatrix(full(Obj.G));
    end

    % test non-square
    assertExceptionThrown(@setnonsquare, 'MATLAB:assert:failed');
    function setnonsquare()
        import org.mensxmachina.graph.ancestormatrix;
        ancestormatrix(Obj.G(:, 1:end-1));
    end

    % test non-DAG
    assertExceptionThrown(@setnondag, 'MATLAB:recursionLimit');
    function setnondag()
        import org.mensxmachina.graph.ancestormatrix;
        G = Obj.G;
        G(4, 1) = 1;
        ancestormatrix(G);
    end

end

function testdefault(Obj)

    import org.mensxmachina.graph.ancestormatrix;

    am = ancestormatrix(Obj.G);
    assertEqual(am, Obj.am);

end

end

end