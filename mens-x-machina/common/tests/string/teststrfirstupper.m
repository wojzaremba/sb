classdef teststrfirstupper < TestCase
%TESTSTRJOIN STRFIRSTUPPER test cases

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
    
    string
    stringFirstUpper
    
end

methods

function Obj = teststrfirstupper(name)

    Obj = Obj@TestCase(name);

    Obj.string = 'string';
    Obj.stringFirstUpper = 'String';

end

function testtoy(Obj)
    
    clc;
    
    import org.mensxmachina.string.strfirstupper;
    
    stringFirstUpper = strfirstupper(Obj.string);
    assertEqual(stringFirstUpper, Obj.stringFirstUpper);
    
end

function testvalidation(Obj)

    clc;
    
    assertExceptionThrown(@setbadstr, 'MATLAB:assert:failed');

    function setbadstr()
        org.mensxmachina.string.strfirstupper(-1i);
    end

end

end

end
