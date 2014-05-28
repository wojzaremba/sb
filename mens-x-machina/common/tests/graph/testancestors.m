classdef testancestors < TestCase
%TESTANCESTORS ANCESTORS test cases

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

end

methods

function Obj = testancestors(name)

    Obj = Obj@TestCase(name);

    Obj.G = sparse(4, 4);

    Obj.G(1, 2) = 1;
    Obj.G(1, 3) = 1;
    Obj.G(2, 4) = 1;
    Obj.G(3, 4) = 1;

end

function testg(Obj)

    clc;

    % test non-sparse
    assertExceptionThrown(@setnonsparse, 'MATLAB:assert:failed');
    function setnonsparse()
        import org.mensxmachina.graph.ancestors;
        ancestors(full(Obj.G), 4);
    end

    % test non-square
    assertExceptionThrown(@setnonsquare, 'MATLAB:assert:failed');
    function setnonsquare()
        import org.mensxmachina.graph.ancestors;
        ancestors(Obj.G(:, 1:end-1),4);
    end

    % test non-DAG
    assertExceptionThrown(@setnondag, 'MATLAB:recursionLimit');
    function setnondag()
        import org.mensxmachina.graph.ancestors;
        G = Obj.G;
        G(4, 1) = 1;
        ancestors(G, 4);
    end

end

function testi(Obj)

    clc;

    % test non-numeric
    assertExceptionThrown(@setnonnumeric, 'MATLAB:invalidType');
    function setnonnumeric()
        import org.mensxmachina.graph.ancestors;
        ancestors(Obj.G, true);
    end

    % test non-real
    assertExceptionThrown(@setnonreal, 'MATLAB:expectedInteger');
    function setnonreal()
        import org.mensxmachina.graph.ancestors;
        ancestors(Obj.G, 1i);
    end

    % test non-scalar
    assertExceptionThrown(@setnonscalar, 'MATLAB:expectedScalar');
    function setnonscalar()
        import org.mensxmachina.graph.ancestors;
        ancestors(Obj.G, [1 2]);
    end

    % test non-integer
    assertExceptionThrown(@setnoninteger, 'MATLAB:expectedInteger');
    function setnoninteger()
        import org.mensxmachina.graph.ancestors;
        ancestors(Obj.G, 1.5);
    end

    % test <= size(G, 2)
    assertExceptionThrown(@setsmall, 'MATLAB:expectedPositive');
    function setsmall()
        import org.mensxmachina.graph.ancestors;
        ancestors(Obj.G, -1);
    end

    % test > size(G, 2)
    assertExceptionThrown(@setbig, 'MATLAB:notLessEqual');
    function setbig()
        import org.mensxmachina.graph.ancestors;
        ancestors(Obj.G, 5);
    end

end

function testdefault(Obj)

    import org.mensxmachina.graph.ancestors;

    an = ancestors(Obj.G, 1);
    assertEqual(an, zeros(1, 0));

    an = ancestors(Obj.G, 2);
    assertEqual(an, 1);

    an = ancestors(Obj.G, 3);
    assertEqual(an, 1);

    an = ancestors(Obj.G, 4);
    assertEqual(an, [1 2 3]);

end

end

end