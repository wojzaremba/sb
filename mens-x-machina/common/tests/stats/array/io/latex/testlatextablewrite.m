classdef testlatextablewrite < TestCase
%TESTLATEXWRITE latextablewrite test cases

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

    dataset
    obsLabels
    varLabels
    
end

methods

function Obj = testlatextablewrite(name)

    Obj = Obj@TestCase(name);

    Obj.dataset = dataset([1; 4; 7], [2; 5; 8], [3; 6; 9]);
    Obj.obsLabels = {'Observation 1', 'Observation 2', 'Observation 3'}';
    Obj.varLabels = {'Variable 1', 'Variable 2', 'Variable 3'};

end

function testdefault(Obj)
    
    clc;

    import org.mensxmachina.stats.array.io.latex.latextablewrite;    

    latextablewrite('default', Obj.dataset);

end

function testspec(Obj)
    
    clc;
    
    import org.mensxmachina.stats.array.io.latex.latextablewrite;

    latextablewrite('spec', Obj.dataset, 'spec', 'l | c || r |');

end

function testformat(Obj)
    
    clc;
    
    import org.mensxmachina.stats.array.io.latex.latextablewrite;

    latextablewrite('format', Obj.dataset, 'format', '%.2f');

end

function testobservationlabels(Obj)
    
    clc;
    
    import org.mensxmachina.stats.array.io.latex.latextablewrite;    

    latextablewrite('observationlabels', Obj.dataset, 'obsLabels', Obj.obsLabels);
    
end

function testvariablelabels(Obj)
    
    clc;
    
    import org.mensxmachina.stats.array.io.latex.latextablewrite;    

    latextablewrite('variablelabels', Obj.dataset, 'varLabels', Obj.varLabels);
    
end

function testvalidation(Obj)

    clc;
    
    assertExceptionThrown(@setnondataset, 'MATLAB:InputParser:ArgumentFailedValidation');

    function setnondataset()
        org.mensxmachina.stats.array.io.latex.latextablewrite('validationtest', ones(2, 2));
    end
    
    assertExceptionThrown(@setbadenvironment, 'MATLAB:InputParser:ArgumentFailedValidation');

    function setbadenvironment()
        org.mensxmachina.stats.array.io.latex.latextablewrite('validationtest', Obj.dataset, 'environment', 'tabbular');
    end
    
    assertExceptionThrown(@setbadspec, 'MATLAB:InputParser:ArgumentFailedValidation');

    function setbadspec()
        org.mensxmachina.stats.array.io.latex.latextablewrite('validationtest', Obj.dataset, 'spec', 1i);
    end
    
    assertExceptionThrown(@setbadformat, 'MATLAB:InputParser:ArgumentFailedValidation');

    function setbadformat()
        org.mensxmachina.stats.array.io.latex.latextablewrite('validationtest', Obj.dataset, 'format', 1i);
    end
    
    assertExceptionThrown(@setwronglengthvarlabels, 'MATLAB:InputParser:ArgumentFailedValidation');

    function setwronglengthvarlabels()
        org.mensxmachina.stats.array.io.latex.latextablewrite('validationtest', Obj.dataset, 'varLabels', {'var1', 'var2', 'var3', 'var4'});
    end
    
    assertExceptionThrown(@setwronglengthobservationlabels, 'MATLAB:InputParser:ArgumentFailedValidation');

    function setwronglengthobservationlabels()
        org.mensxmachina.stats.array.io.latex.latextablewrite('validationtest', Obj.dataset, 'obsLabels', {'obs1', 'obs2'});
    end

end

end

end