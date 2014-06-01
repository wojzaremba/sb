classdef testtabpotential < TestCase

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
    
    A
    B
    C
    M
    
    A_categorical
    
    Empty

end

methods

function Obj = testtabpotential(name)
    
    clc;

    import org.mensxmachina.stats.cpd.tabular.tabpotential;
    
    % Example in Artificial Intelligence: a Modern Approach (Third
    % Edition), p. 527, Fig. 14.10

    Obj = Obj@TestCase(name);
    
    values = [0.3 0.7 0.9 0.1];
    values = reshape(values, [2 2]);
    values = permute(values, [2 1]);
    
    Obj.A = tabpotential(...
        {'A', 'B'}, ...
        {[1; 2], [1; 2]}, ...
        values);
    
    Obj.A_categorical = tabpotential(...
        {'A', 'B'}, ...
        {nominal([1; 2], {'value1', 'val2'}), nominal([1; 2], {'val1', 'value2'})}, ...
        values);
    
    values = [0.2 0.8 0.6 0.4];
    values = reshape(values, [2 2]);
    values = permute(values, [2 1]);
    
    Obj.B = tabpotential(...
        {'B', 'C'}, ...
        {[1; 2], [1; 2]}, ...
        values);
    
    values = [0.06 0.24 0.42 0.28 0.18 0.72 0.06 0.04];
    values = reshape(values, [2 2 2]);
    values = permute(values, [3 2 1]);
    
    Obj.C = tabpotential(...
        {'A', 'B', 'C'}, ...
        {[1; 2], [1; 2], [1; 2]}, ...
        values); 
    
    values = [0.3 0.7 0.9 0.1];
    values = reshape(values, [2 2]);
    values = permute(values, [2 1]);
    
    Obj.M = tabpotential(...
        {'A', 'B'}, ...
        {[1; 2], [1; 2]}, ...
        values);  
    
    Obj.Empty = tabpotential(cell(1, 0), cell(1, 0), zeros(1, 1));

end

function testtimes(Obj)

    clc;
    
    C = permute(Obj.A, randperm(length(Obj.A.varNames))).*permute(Obj.B, randperm(length(Obj.B.varNames)));    
    
    assertElementsAlmostEqual(C.values, Obj.C.values);

end

function testsum(Obj)

    clc;

    M = sum(Obj.C, 3);
    assertElementsAlmostEqual(M.values, Obj.M.values);

end

function testdisplay(Obj)
    
    clc;

    Obj.A
    
end

function testdisplayempty(Obj)
    
    clc;

    Obj.Empty
    
end

function testdisplayvariablelength(Obj)
    
    clc;

    Obj.A_categorical
    
end

end

end