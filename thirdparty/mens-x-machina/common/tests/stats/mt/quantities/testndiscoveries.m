classdef testndiscoveries < TestCase
%TESTNDISCOVERIES NDISCOVERIES test cases

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
    
    p
    t
    r 
    
end

methods

function Obj = testndiscoveries(name)

    Obj = Obj@TestCase(name);

    Obj.p = [0.001 0.01 0.05 0.1 0.5 1]';
    Obj.t = Obj.p;
    Obj.r = [1 2 3 4 5 6]';
    
    pOrder = randperm(length(Obj.p));
    Obj.p = Obj.p(pOrder);
    
    tOrder = randperm(length(Obj.t));
    Obj.t = Obj.t(tOrder);
    Obj.r = Obj.r(tOrder);

end

function testp(Obj)

    assertExceptionThrown(@setnonnumericrealstat, 'MATLAB:invalidType');
    function setnonnumericrealstat()
        org.mensxmachina.stats.mt.quantities.ndiscoveries('cccccc', Obj.t)
    end

    assertExceptionThrown(@setnonrealstat, 'MATLAB:expectedReal');
    function setnonrealstat()
        org.mensxmachina.stats.mt.quantities.ndiscoveries(complex(Obj.p, zeros(size(Obj.p))), Obj.t);
    end
    
end

function testthresholds(Obj)
    
    clc;

    assertExceptionThrown(@setnonnumericthreshold, 'MATLAB:invalidType');
    function setnonnumericthreshold()
        org.mensxmachina.stats.mt.quantities.ndiscoveries(Obj.p, 'cccccc');
    end

    assertExceptionThrown(@setnonrealstatthresh, 'MATLAB:expectedReal');
    function setnonrealstatthresh()
        org.mensxmachina.stats.mt.quantities.ndiscoveries(Obj.p, complex(Obj.p, zeros(size(Obj.p))));
    end
    
end

function testr(Obj)
    
    clc;

    r = org.mensxmachina.stats.mt.quantities.ndiscoveries(Obj.p, Obj.t);
    assertEqual(r, Obj.r);
    
    % empty thresholds
    r = org.mensxmachina.stats.mt.quantities.ndiscoveries(Obj.p, zeros(0, 1));    
    assertEqual(r, zeros(0, 1));
    
end

function testempty(Obj)
 
    ndiscoveries = org.mensxmachina.stats.mt.quantities.ndiscoveries(zeros(0, 1), zeros(0, 1));    
    assertTrue(isempty(ndiscoveries));
  
end

end

end
