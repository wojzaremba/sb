classdef testtabcpd < TestCase

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
    
    emptyCpd
    emptyYCpd
    emptyXCpd

    cpd
    
    n
    dy

end

methods

function Obj = testtabcpd(name)

    clc;

    import org.mensxmachina.stats.cpd.cpdvartype;
    import org.mensxmachina.stats.cpd.tabular.tabcpd;

    Obj = Obj@TestCase(name);
    
    e = cpdvartype.Explanatory;
    r = cpdvartype.Response;
    
    varTypes = [e e r r];

    Obj.emptyCpd = tabcpd(cell(1, 0), cell(1, 0), cpdvartype.empty(1, 0), ones(1, 1));
    Obj.emptyYCpd = tabcpd({'x'}, {nominal((1:2)')}, r, ones(2, 1)/2);
    Obj.emptyXCpd = tabcpd({'y'}, {nominal((1:2)')}, e, ones(2, 1));
    
    values = ones(6, 6)/6;
    values = reshape(values, [2 3 3 2]);
    
    Obj.cpd = tabcpd(...
        {'Variable1', 'Var2', 'Variable3', 'Var4'}, ...
        {nominal((1:2)'), nominal((1:3)'), nominal((1:3)'), nominal((1:2)')}, ...
        varTypes, values);

    Obj.n = 10;
    Obj.dy = dataset(nominal(randi(2, Obj.n, 1)), nominal(randi(3, Obj.n, 1)), 'VarNames', {'Variable1', 'Var2'});
    
end

% function testparserandominput(Obj)
%     
%     clc;
% 
%     % test non-dataset
%     assertExceptionThrown(@setnondataset, 'MATLAB:assert:failed');
%     function setnondataset()
%         Obj.cpd.arevalidexplanatoryvariablevalues('char');
%     end
% 
%     % test bad size dataset 
%     assertExceptionThrown(@setbadsizedataset, 'MATLAB:assert:failed');
%     function setbadsizedataset()
%         Obj.cpd.arevalidexplanatoryvariablevalues(Obj.dy(:, 1));
%     end
% 
%     % test missing variable dataset
%     assertExceptionThrown(@setmissingvariabledataset, 'MATLAB:assert:failed');
%     function setmissingvariabledataset()
%         dy = Obj.dy;
%         dy.Properties.varNames{1} = 'bad';
%         Obj.cpd.arevalidexplanatoryvariablevalues(dy);
%     end
%     
%     tf = Obj.cpd.arevalidexplanatoryvariablevalues(Obj.dy);
%     assertTrue(tf);
%     
%     dy = Obj.dy;
%     dy{1, 1} = '3';
%     tf = Obj.cpd.arevalidexplanatoryvariablevalues(dy);
%     assertFalse(tf);
%     
% end

function testrandom(Obj)
    
    clc;
    
    import org.mensxmachina.stats.cpd.cpdvartype;
    
    % test random
    reset(RandStream.getDefaultStream);
    dx = Obj.cpd.random(Obj.dy);
    assertEqual(dx.Properties.VarNames, Obj.cpd.varNames(Obj.cpd.varTypes == cpdvartype.Response));
    %assertTrue(all(arrayfun(@(i) all(Obj.cpd.ResponseVariableDomains{i}.hasmember(dx.(dx.Properties.varNames{i}))), 1:length(Obj.cpd.varNames))));
    
end

function testsubsref(Obj)
    
    clc;
    
    levels = cellfun(@getlevels, Obj.cpd.varValues, 'UniformOutput', false);
    
    assertEqual(Obj.cpd(levels{1}(1), levels{2}(2), levels{3}(3), levels{4}(1)), Obj.cpd.values(1, 2, 3, 1));
    assertEqual(length(Obj.cpd.varNames), 4);

    % use {}
    assertExceptionThrown(@usecellsubs, 'MATLAB:numel:BadSubscriptingIndex');
    function usecellsubs()
        Obj.cpd{levels{1}(1), levels{2}(2), levels{3}(3), levels{4}(1)}
    end
    
end

function testend(Obj)
    
    import org.mensxmachina.stats.cpd.tabular.tabcpd;
    
    Obj.cpd(1, 2, 3, end)
    
end

function testnumel(Obj)
    
    numel(Obj.cpd)
    numel(Obj.cpd, 1, 2, 3)
    numel(Obj.cpd, 1, 2, 3, 1)
    
end

function testpermute(Obj)
    
    order = randperm(length(Obj.cpd.varNames))
    
    Obj.cpd
    
    cpd = permute(Obj.cpd, order);
    
    cpd
    
    cpd = ipermute(cpd, order);
    
    assertEqual(cpd, Obj.cpd);
    
end

function testdisplay(Obj)

    clc;

    import org.mensxmachina.stats.cpd.cpdvartype;
    import org.mensxmachina.stats.cpd.tabular.tabcpd;
    
    e = cpdvartype.Explanatory;
    r = cpdvartype.Response;
    
    % test empty
    Obj.emptyCpd
    
    % test empty dy
    Obj.emptyYCpd
    
    % test empty X
    Obj.emptyXCpd
    
    % test default
    Obj.cpd
    
    % test floats
    varNames = {'a', 'b', 'c', 'd'};
    varTypes = [e e r r];
    varValues = {[1.5; 3.456], [1.2345; 6.789; 7.89], [1.1; 4.567; 8.9], [1; 9.8]};
    values = ones(6, 6)/6;
    values = reshape(values, [2 3 3 2]);
    cpd = tabcpd(varNames, varValues, varTypes, values);
    cpd
    
    % test variable label length
    varNames = {'a', 'b', 'c', 'd'};
    varTypes = [e e r r];
    varValues = {nominal(1:2, {'value1', 'val2'})', nominal(1:3)', nominal(1:3, {'val1', 'value2', 'val3'})', nominal(1:2)'};
    values = ones(6, 6)/6;
    values = reshape(values, [2 3 3 2]);
    cpd = tabcpd(varNames, varValues, varTypes, values);
    cpd  
    
end

end

end