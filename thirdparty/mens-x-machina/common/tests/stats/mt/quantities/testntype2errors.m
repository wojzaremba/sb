classdef testntype2errors < TestCase
%TESTNTYPE2ERRORS ORG.MENSXMACHINA.STATS.MT.QUANTITIES.NTYPE2ERRORS test cases

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
    h
    thresholds
    t
    
end

methods

function Obj = testntype2errors(name)

    Obj = Obj@TestCase(name);

    Obj.p = [0.001 0.01 0.05 0.1 0.5 1]';
    Obj.h = logical([1 1 0 0 0 0])';
    Obj.thresholds = Obj.p;
    Obj.t = [1 0 0 0 0 0]';

    perm = randperm(length(Obj.p));
    
    Obj.p = Obj.p(perm);
    Obj.h = Obj.h(perm);

    perm = randperm(length(Obj.thresholds));
    
    Obj.thresholds = Obj.thresholds(perm);
    Obj.t = Obj.t(perm);

end

function testp(Obj)

    clc;

    assertExceptionThrown(@setnonnumericp, 'MATLAB:invalidType');
    function setnonnumericp()
        org.mensxmachina.stats.mt.quantities.ntype2errors('cccccc', Obj.h, Obj.thresholds);
    end

    assertExceptionThrown(@setnonrealp, 'MATLAB:expectedReal');
    function setnonrealp()
        org.mensxmachina.stats.mt.quantities.ntype2errors(complex(Obj.p, zeros(size(Obj.p))), Obj.h, Obj.thresholds);
    end
    
end

function testthresholds(Obj)

    clc;

    assertExceptionThrown(@setnonnumericthresholds, 'MATLAB:invalidType');
    function setnonnumericthresholds()
        org.mensxmachina.stats.mt.quantities.ntype2errors(Obj.p, Obj.h, 'cccccc')
    end

    assertExceptionThrown(@setnonrealthresholds, 'MATLAB:expectedReal');
    function setnonrealthresholds()
        org.mensxmachina.stats.mt.quantities.ntype2errors(Obj.p, Obj.h, complex(Obj.thresholds, zeros(size(Obj.thresholds))))
    end
    
end

function testh(Obj)

    clc;

    assertExceptionThrown(@setnonlogicalh, 'MATLAB:invalidType');
    function setnonlogicalh()
        org.mensxmachina.stats.mt.quantities.ntype2errors(Obj.p, double(Obj.h), Obj.thresholds);
    end

    assertExceptionThrown(@setbadsizeh, 'MATLAB:incorrectSize');
    function setbadsizeh()
        org.mensxmachina.stats.mt.quantities.ntype2errors(Obj.p, [Obj.h; false], Obj.thresholds);
    end
    
    % test sparse is OK
    org.mensxmachina.stats.mt.quantities.ntype2errors(Obj.p, sparse(Obj.h), Obj.thresholds);

end

function testt(Obj)

    clc;

    t = org.mensxmachina.stats.mt.quantities.ntype2errors(Obj.p, Obj.h, Obj.thresholds);
    assertEqual(t, Obj.t);
    
end

end

end
