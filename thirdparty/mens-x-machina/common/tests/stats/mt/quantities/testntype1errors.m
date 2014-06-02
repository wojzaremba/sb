classdef testntype1errors < TestCase
%TESTNTYPE1ERRORS NTYPE1ERRORS test cases

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
    t
    v
    
end

methods

function Obj = testntype1errors(name)

    Obj = Obj@TestCase(name);

    Obj.p = [0.001 0.01 0.05 0.1 0.5 1]';
    Obj.h = logical([1 1 0 0 0 0])';
    Obj.t = Obj.p;
    Obj.v = [0 0 1 2 3 4]';

    perm = randperm(length(Obj.p));
    
    Obj.p = Obj.p(perm);
    Obj.h = Obj.h(perm);
    
    perm = randperm(length(Obj.t));
    
    Obj.t = Obj.t(perm);
    Obj.v = Obj.v(perm);

end

function testp(Obj)

    clc;

    assertExceptionThrown(@setnonnumericrealstat, 'MATLAB:invalidType');
    function setnonnumericrealstat()
        org.mensxmachina.stats.mt.quantities.ntype1errors('cccccc', Obj.h, Obj.t);
    end

    assertExceptionThrown(@setnonrealstat, 'MATLAB:expectedReal');
    function setnonrealstat()
        org.mensxmachina.stats.mt.quantities.ntype1errors(complex(Obj.p, zeros(size(Obj.p))), Obj.h, Obj.t);
    end
    
end
  
function testh(Obj)

    clc;

    assertExceptionThrown(@setnonlogicalh, 'MATLAB:invalidType');
    function setnonlogicalh()
        org.mensxmachina.stats.mt.quantities.ntype1errors(Obj.p, double(Obj.h), Obj.t);
    end

    assertExceptionThrown(@setbadnumelh, 'MATLAB:incorrectSize');
    function setbadnumelh()
        org.mensxmachina.stats.mt.quantities.ntype1errors(Obj.p, [Obj.h; false], Obj.t);
    end
    
    % test sparse is OK
    org.mensxmachina.stats.mt.quantities.ntype1errors(Obj.p, sparse(Obj.h), Obj.t);

end

function testt(Obj)

    clc;

    assertExceptionThrown(@setnonnumericthresholds, 'MATLAB:invalidType');
    function setnonnumericthresholds()
        org.mensxmachina.stats.mt.quantities.ntype1errors(Obj.p, Obj.h, 'cccccc');
    end

    assertExceptionThrown(@setnonrealthresholds, 'MATLAB:expectedReal');
    function setnonrealthresholds()
        org.mensxmachina.stats.mt.quantities.ntype1errors(Obj.p, Obj.h, complex(Obj.t, zeros(size(Obj.t))));
    end
    
end

function testv(Obj)

    clc;

    v = org.mensxmachina.stats.mt.quantities.ntype1errors(Obj.p, Obj.h, Obj.t);
    assertEqual(v, Obj.v);

end

end

end
