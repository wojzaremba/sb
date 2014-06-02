classdef testisdsep < TestCase
%TESTISDSEP ISDSEP test cases

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

    m
    v

    indCEmpty
    indBEmpty

    indC
    indB
    indA

end

methods

function Obj = testisdsep(name)   

    Obj = Obj@TestCase(name);

    Obj.G = sparse(10, 10);

    Obj.G(1, 3) = 1;
    Obj.G(1, 4) = 1;
    Obj.G(2, 5) = 1;
    Obj.G(2, 6) = 1;
    Obj.G(3, 6) = 1;
    Obj.G(3, 7) = 1;
    Obj.G(4, 8) = 1;
    Obj.G(7, 9) = 1;
    Obj.G(8, 9) = 1;
    Obj.G(8, 10) = 1;

    Obj.m = 10;
    Obj.v = 1:Obj.m;

    Obj.indCEmpty = {1, 1, 2, 2, 2, 2, 2,  2, 3, 4, 5, 5, 5,  5};
    Obj.indBEmpty = {2, 5, 3, 4, 7, 8, 9, 10, 5, 5, 7, 8, 9, 10};

    Obj.indC{1} = {1, 1, 1, 1, 1, 1,  1, 1, 1, 1, 1, 1, 1,  1, 1, 1, 1,  1,  1, 2, 2, 2, 2, 2, 2,  2, 2, 2, 2, 2, 2, 2,  2, 2, 2, 2, 2, 2, 2,  2, 2, 2, 2, 2, 2, 2, 2,  2, 2, 2, 2, 2, 2, 2,  2,  2,  2,  2,  2,  2,  2,  2, 3, 3, 3, 3, 3, 3, 3,  3, 3, 3,  3,  3,  3, 4, 4, 4, 4, 4, 4,  4, 4, 4, 4, 4,  4, 5, 5, 5, 5, 5, 5, 5, 5, 5,  5, 5, 5, 5, 5, 5, 5,  5, 5, 5, 5, 5, 5, 5,  5,  5,  5,  5,  5,  5,  5,  5, 6, 6, 6, 6, 6,  6,  6,  6,  6, 7, 7, 7,  7,  7,  7,  7,  9};
    Obj.indB{1} = {2, 2, 2, 2, 2, 2,  2, 5, 5, 5, 5, 5, 5,  5, 6, 7, 8, 10, 10, 3, 3, 3, 3, 3, 3,  3, 4, 4, 4, 4, 4, 4,  4, 7, 7, 7, 7, 7, 7,  7, 8, 8, 8, 8, 8, 8, 8,  8, 9, 9, 9, 9, 9, 9,  9, 10, 10, 10, 10, 10, 10, 10, 4, 5, 5, 5, 5, 5, 5,  5, 8, 8, 10, 10, 10, 5, 5, 5, 5, 5, 5,  5, 6, 6, 7, 7, 10, 6, 7, 7, 7, 7, 7, 7, 7, 7,  7, 8, 8, 8, 8, 8, 8,  8, 9, 9, 9, 9, 9, 9,  9, 10, 10, 10, 10, 10, 10, 10, 7, 8, 8, 8, 9, 10, 10, 10, 10, 8, 8, 8, 10, 10, 10, 10, 10};
    Obj.indA{1} = {3, 4, 5, 7, 8, 9, 10, 2, 3, 4, 7, 8, 9, 10, 3, 3, 4,  4,  8, 1, 4, 5, 7, 8, 9, 10, 1, 3, 5, 7, 8, 9, 10, 1, 3, 4, 5, 8, 9, 10, 1, 3, 4, 5, 7, 8, 9, 10, 1, 3, 4, 5, 7, 8, 10,  1,  3,  4,  5,  7,  8,  9, 1, 1, 2, 4, 7, 8, 9, 10, 1, 4,  1,  4,  8, 1, 2, 3, 7, 8, 9, 10, 1, 3, 1, 3,  8, 2, 1, 2, 3, 4, 5, 7, 8, 9, 10, 1, 2, 3, 4, 7, 9, 10, 1, 2, 3, 4, 7, 8, 10,  1,  2,  3,  4,  7,  8,  9, 3, 1, 3, 4, 3,  1,  3,  4,  8, 1, 3, 4,  1,  3,  4,  8,  8};

    Obj.indC{2} = {1, 3, 4};
    Obj.indB{2} = {9, 9, 9};
    Obj.indA{2} = {[3 4], [1 7], [1 8]};

    %{
    Obj.indCEmpty = {1, 1, 3, 3, 4, 4, 7, 7, 8, 8, 9, 9, 10, 10};
    Obj.indBEmpty = {2, 5, 2, 5, 4, 5, 2, 5, 2, 5, 2, 5, 2, 5};

    Obj.indC{1} = {1, 1, 1, 1, 3, 3, 3, 4, 4, 4, 5, 6, 6, 6, 6, 7, 7};
    Obj.indB{1} = {6, 7, 8, 9, 4, 8, 10, 6, 10, 7, 6, 7, 8, 9, 10, 8, 10};
    Obj.indA{1} = {3, 3, 4, 4, 1, 1, 1, 1, 8, 1, 2, 3, 3, 3, 3, 3, 3};

    Obj.indC{2} = {1, 3, 4};
    Obj.indB{2} = {9, 9, 9};
    Obj.indA{2} = {[3 4], [1 7], [1 8]};
    %}

end

function testg(Obj)

    clc;

    % test non-sparse
    assertExceptionThrown(@setnonsparse, 'MATLAB:assert:failed');
    function setnonsparse()
        import org.mensxmachina.graph.isdsep;
        isdsep(full(Obj.G), [1 2], [3 4], [5 6]);
    end

    % test non-square
    assertExceptionThrown(@setnonsquare, 'MATLAB:assert:failed');
    function setnonsquare()
        import org.mensxmachina.graph.isdsep;
        isdsep(Obj.G(:, 1:end-1), [1 2], [3 4], [5 6]);
    end

    % test non-DAG
    assertExceptionThrown(@setnondag, 'MATLAB:recursionLimit');
    function setnondag()
        import org.mensxmachina.graph.isdsep;
        G = Obj.G;
        G(6, 1) = 1;
        isdsep(G, [1 2], [3 4], [5 6]);
    end

end

function testc(Obj)

    clc;

    % test non-numeric
    assertExceptionThrown(@setnonnumeric, 'MATLAB:invalidType');
    function setnonnumeric()
        import org.mensxmachina.graph.isdsep;
        isdsep(Obj.G, logical([1 2]), [3 4], [5 6]);
    end

    % test non-real
    assertExceptionThrown(@setnonreal, 'MATLAB:expectedInteger');
    function setnonreal()
        import org.mensxmachina.graph.isdsep;
        isdsep(Obj.G, complex([1 2], [0 0]), [3 4], [5 6]);
    end

    % test non-vector
    assertExceptionThrown(@setnonvector, 'MATLAB:expectedVector');
    function setnonvector()
        import org.mensxmachina.graph.isdsep;
        isdsep(Obj.G, reshape([1 2], 1, 1, zeros(0, 1)), [3 4], [5 6]);
    end

    % test non-integer
    assertExceptionThrown(@setnoninteger, 'MATLAB:expectedInteger');
    function setnoninteger()
        import org.mensxmachina.graph.isdsep;
        isdsep(Obj.G, [1.5 2], [3 4], [5 6]);
    end

    % test <= size(G, 2)
    assertExceptionThrown(@setsmall, 'MATLAB:notGreaterEqual');
    function setsmall()
        import org.mensxmachina.graph.isdsep;
        isdsep(Obj.G, [-1 2], [3 4], [5 6]);
    end

    % test > size(G, 2)
    assertExceptionThrown(@setbig, 'MATLAB:notLessEqual');
    function setbig()
        import org.mensxmachina.graph.isdsep;
        isdsep(Obj.G, [11 2], [3 4], [5 6]);
    end

end

function testb(Obj)

    clc;

    % test non-numeric
    assertExceptionThrown(@setnonnumeric, 'MATLAB:invalidType');
    function setnonnumeric()
        import org.mensxmachina.graph.isdsep;
        isdsep(Obj.G, [3 4], logical([1 2]), [5 6]);
    end

    % test non-real
    assertExceptionThrown(@setnonreal, 'MATLAB:expectedInteger');
    function setnonreal()
        import org.mensxmachina.graph.isdsep;
        isdsep(Obj.G, [3 4], complex([1 2], [0 0]), [5 6]);
    end

    % test non-vector
    assertExceptionThrown(@setnonvector, 'MATLAB:expectedVector');
    function setnonvector()
        import org.mensxmachina.graph.isdsep;
        isdsep(Obj.G, [3 4], reshape([1 2], 1, 1, zeros(0, 1)), [5 6]);
    end

    % test non-integer
    assertExceptionThrown(@setnoninteger, 'MATLAB:expectedInteger');
    function setnoninteger()
        import org.mensxmachina.graph.isdsep;
        isdsep(Obj.G, [3 4], [1.5 2], [5 6]);
    end

    % test <= size(G, 2)
    assertExceptionThrown(@setsmall, 'MATLAB:notGreaterEqual');
    function setsmall()
        import org.mensxmachina.graph.isdsep;
        isdsep(Obj.G, [3 4], [-1 2], [5 6]);
    end

    % test > size(G, 2)
    assertExceptionThrown(@setbig, 'MATLAB:notLessEqual');
    function setbig()
        import org.mensxmachina.graph.isdsep;
        isdsep(Obj.G, [3 4], [11 2], [5 6]);
    end

end

function testa(Obj)

    clc;

    % test non-numeric
    assertExceptionThrown(@setnonnumeric, 'MATLAB:invalidType');
    function setnonnumeric()
        import org.mensxmachina.graph.isdsep;
        isdsep(Obj.G, [3 4], [5 6], logical([1 2]));
    end

    % test non-real
    assertExceptionThrown(@setnonreal, 'MATLAB:expectedInteger');
    function setnonreal()
        import org.mensxmachina.graph.isdsep;
        isdsep(Obj.G, [3 4], [5 6], complex([1 2], [0 0]));
    end

    % test non-vector
    assertExceptionThrown(@setnonvector, 'MATLAB:expectedVector');
    function setnonvector()
        import org.mensxmachina.graph.isdsep;
        isdsep(Obj.G, [3 4], [5 6], reshape([1 2], 1, 1, zeros(0, 1)));
    end

    % test non-integer
    assertExceptionThrown(@setnoninteger, 'MATLAB:expectedInteger');
    function setnoninteger()
        import org.mensxmachina.graph.isdsep;
        isdsep(Obj.G, [3 4], [5 6], [1.5 2]);
    end

    % test <= size(G, 2)
    assertExceptionThrown(@setsmall, 'MATLAB:notGreaterEqual');
    function setsmall()
        import org.mensxmachina.graph.isdsep;
        isdsep(Obj.G, [3 4], [5 6], [-1 2]);
    end

    % test > size(G, 2)
    assertExceptionThrown(@setbig, 'MATLAB:notLessEqual');
    function setbig()
        import org.mensxmachina.graph.isdsep;
        isdsep(Obj.G, [3 4], [5 6], [11 2]);
    end

    % test overlap with b
    assertExceptionThrown(@setoverlapwithb, 'MATLAB:assert:failed');
    function setoverlapwithb()
        import org.mensxmachina.graph.isdsep;
        isdsep(Obj.G, [3 4], [5 6], [5 2]);
    end

end

%{
function testprev(Obj)

G = sparse(4, 4);
G(1,2) = 1;
G(2,3) = 1;
G(4,2) = 1;
G(4,3) = 1;

view(biograph(G));

dsep_prev = findDSeparations(G, 3, 2) % FAIL
dsep = isdsep(G, zeros(0, 1), 3, 2);
find(dsep)

end
%}

function testdefault(Obj)

    import org.mensxmachina.graph.*;

    %view(biograph(Obj.G, {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10'}));

    for j1=Obj.v % for each variable

        for j2=(j1 + 1):Obj.m % for each next variable

            fprintf('\nFinding dsep(%d, %d, zeros(0, 1))...\n', j1, j2);

            % quick with nonempty C and cache
            j1IsDSepWithJ2GivenJ3 = isdsep(Obj.G, j1, j2, zeros(0, 1));
            assertEqual(j1IsDSepWithJ2GivenJ3, ~isempty( find( cellfun(@(j) j == j1, Obj.indCEmpty) & cellfun(@(j) j == j2, Obj.indBEmpty), 1) ) );

            % quick with nonempty C and without cache
            j1IsDSepWithJ2GivenJ3_2 = isdsep(Obj.G, j1, j2, zeros(0, 1));
            assertEqual(j1IsDSepWithJ2GivenJ3_2, j1IsDSepWithJ2GivenJ3);

            % quick with empty C and cache
            isDSepWithJ2GivenJ3 = isdsep(Obj.G, zeros(0, 1), j2, zeros(0, 1));
            assertEqual(isDSepWithJ2GivenJ3(j1), j1IsDSepWithJ2GivenJ3);

            % quick with empty C and without cache
            [isDSepWithJ2GivenJ3] = isdsep(Obj.G, zeros(0, 1), j2, zeros(0, 1));
            assertEqual(isDSepWithJ2GivenJ3(j1), j1IsDSepWithJ2GivenJ3);

            % non-quick with nonempty C
            j1IsDSepWithJ2GivenJ3_2 = isdsep(Obj.G, j1, j2, zeros(0, 1));
            assertEqual(j1IsDSepWithJ2GivenJ3_2, j1IsDSepWithJ2GivenJ3);

            % non-quick with empty C
            isDSepWithJ2GivenJ3 = isdsep(Obj.G, zeros(0, 1), j2, zeros(0, 1));
            assertEqual(isDSepWithJ2GivenJ3(j1), j1IsDSepWithJ2GivenJ3);

            for nj3 = 1:2 % for each cardinality up to 2

                C3 = nchoosek(setdiff(Obj.v, [j1 j2]), nj3);

                for k3 = 1:size(C3, 1) % for each subset of this cardinality

                    j3 = C3(k3, :);

                    fprintf('\nFinding dsep(%d, %d, %s)...\n', j1, j2, num2str(j3));

                    if nj3 == 2 && isempty( find( cellfun(@(j) j == j1, Obj.indC{nj3}) & cellfun(@(j) j == j2, Obj.indB{nj3}) & cellfun(@(j) isequal(j, j3), Obj.indA{nj3}),  1) )
                        continue;
                    end

                    %fprintf('\nFinding dsep(%d, %d, %s)...\n', j1, j2, num2str(j3));

                    % quick with nonempty C and cache
                    j1IsDSepWithJ2GivenJ3 = isdsep(Obj.G, j1, j2, j3);

                    assertEqual(j1IsDSepWithJ2GivenJ3, ~isempty( find( cellfun(@(j) j == j1, Obj.indC{nj3}) & cellfun(@(j) j == j2, Obj.indB{nj3}) & cellfun(@(j) isequal(j, j3), Obj.indA{nj3}),  1) ) );

                    % quick with nonempty C and without cache
                    j1IsDSepWithJ2GivenJ3_2 = isdsep(Obj.G, j1, j2, j3);
                    assertEqual(j1IsDSepWithJ2GivenJ3_2, j1IsDSepWithJ2GivenJ3);

                    % quick with empty C and cache
                    isDSepWithJ2GivenJ3 = isdsep(Obj.G, zeros(0, 1), j2, j3);
                    assertEqual(isDSepWithJ2GivenJ3(j1), j1IsDSepWithJ2GivenJ3);

                    % quick with empty C and without cache
                    [isDSepWithJ2GivenJ3] = isdsep(Obj.G, zeros(0, 1), j2, j3);
                    assertEqual(isDSepWithJ2GivenJ3(j1), j1IsDSepWithJ2GivenJ3);

                    % non-quick with nonempty C
                    j1IsDSepWithJ2GivenJ3_2 = isdsep(Obj.G, j1, j2, j3);
                    assertEqual(j1IsDSepWithJ2GivenJ3_2, j1IsDSepWithJ2GivenJ3);

                    % non-quick with empty C
                    isDSepWithJ2GivenJ3 = isdsep(Obj.G, zeros(0, 1), j2, j3);
                    assertEqual(isDSepWithJ2GivenJ3(j1), j1IsDSepWithJ2GivenJ3);

                end

            end

        end

    end

end

end

end