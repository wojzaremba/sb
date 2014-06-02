classdef testbdeucpdlearner < TestCase
%TESTLEARNPARAM BNETRNDPARAMLEARN test cases

% Copyright 2010-2012 Mens X Machina
% 
% This file is part of Mens X Machina Probabilistic Graphical Model
% Toolbox.
% 
% Mens X Machina Probabilistic Graphical Model Toolbox is free software:
% you can redistribute it and/or modify it under the terms of the GNU
% General Public License alished by the Free Software Foundation, either
% version 3 of the License, or (at your option) any later version.
% 
% Mens X Machina Probabilistic Graphical Model Toolbox is distributed in
% the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
% the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
% PURPOSE. See the GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License along
% with Mens X Machina Probabilistic Graphical Model Toolbox. If not, see
% <http://www.gnu.org/licenses/>.

properties
    
    varNames
    varValues
    structure
    cpd
    
    cpdLearner
    
end

methods

function Obj = testbdeucpdlearner(name)
    
    import org.mensxmachina.stats.array.datasetvarvalues;
    import org.mensxmachina.pgm.bn.learning.cpd.bdeu.bdeucpdlearner;
    
    clc;

    Obj = Obj@TestCase(name);
    
    load('alarm_bayesnet', 'BayesNet');
    load('alarm_bayesnet_sample', 'Sample');
    
    Obj.cpd = BayesNet.cpd;        
    Obj.varNames = BayesNet.varNames;
    Obj.varValues = datasetvarvalues(Sample);
    Obj.structure = BayesNet.structure;
    
    sample = double(Sample);
    
    Obj.varValues{:}
    
    Obj.cpdLearner = bdeucpdlearner(Obj.varNames, Obj.varValues, Obj.structure, sample); 

end

function testlearncpd(Obj)
    
    clc;

    % learn CPDs
    cpd1 = Obj.cpdLearner.learncpd();
    
%     cpd = cpd1;
%     
%     save('testbdeucpdlearner_testlearncpd', 'cpd');
    
    load('testbdeucpdlearner_testlearncpd', 'cpd');
    
    assertEqual(cpd, cpd1);
    
    mae = zeros(size(Obj.varNames));

    for i = 1:length(Obj.varNames)
        
        iCpd = cpd1{i};
        iTrueCpd = Obj.cpd{i};
        
        e = iCpd.values - iTrueCpd.values;
        e = e(:);
        
        ae = abs(e);
        mae(i) = mean(ae);

    end
    
    mean(mae)
    
end

end

end