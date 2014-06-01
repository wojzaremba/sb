classdef testjtreeinfengine < TestCase
%TESTJTREEINFENGINE JTREEINFENGINE test cases

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
    
bayesNet
evidence
varWeights
    
end

methods

function Obj = testjtreeinfengine(name)
    
    import org.mensxmachina.stats.cpd.cpdvartype;
    import org.mensxmachina.stats.cpd.tabular.*;
    import org.mensxmachina.pgm.bn.bayesnet;

    Obj = Obj@TestCase(name);
    
    % PPTC p.4

    structure = [...
        0 1 1 0 0 0 0 0;
        0 0 0 1 0 0 0 0;
        0 0 0 0 1 0 1 0;
        0 0 0 0 0 1 0 0;
        0 0 0 0 0 1 0 1;
        0 0 0 0 0 0 0 0;
        0 0 0 0 0 0 0 1;
        0 0 0 0 0 0 0 0;
        ];

    structure = sparse(structure);
    
    r = cpdvartype.Response;
    e = cpdvartype.Explanatory;

    Obj.varWeights = 2*ones(1, 8);
    
    varValues = repmat({nominal([1; 2], {'on', 'off'})}, 1, 8);
    varNames = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'};

    cpd = cell(1, 8);
    
    % A

    cpdVarInd = 1;
    cpdVarTypes = r;    
    values = reshape([0.5 0.5], [2 1]);
    
    cpd{1} = tabcpd(varNames(cpdVarInd), varValues(cpdVarInd), cpdVarTypes, values);
    
    % B

    cpdVarInd = [1 2];
    cpdVarTypes = [e r];    
    values = reshape([0.5 0.4 0.5 0.6], [2 2]);
    
    cpd{2} = tabcpd(varNames(cpdVarInd), varValues(cpdVarInd), cpdVarTypes, values);

    % C

    cpdVarInd = [1 3];
    cpdVarTypes = [e r];   
    values = reshape([0.7 0.2 0.3 0.8], [2 2]);
    
    cpd{3} = tabcpd(varNames(cpdVarInd), varValues(cpdVarInd), cpdVarTypes, values);

    % D

    cpdVarInd = [2 4];
    cpdVarTypes = [e r];  
    values = reshape([0.9 0.5 0.1 0.5], [2 2]);
    
    cpd{4} = tabcpd(varNames(cpdVarInd), varValues(cpdVarInd), cpdVarTypes, values);

    % E

    cpdVarInd = [3 5];
    cpdVarTypes = [e r];
    values = reshape([0.3 0.6 0.7 0.4], [2 2]);
    
    cpd{5} = tabcpd(varNames(cpdVarInd), varValues(cpdVarInd), cpdVarTypes, values);

    % F

    cpdVarInd = [4 5 6];
    cpdVarTypes = [e e r];
    values = reshape([0.01 0.01 0.01 0.99 0.99 0.99 0.99 0.01], [2 2 2]);
    values = permute(values, [2 1 3]);
    
    cpd{6} = tabcpd(varNames(cpdVarInd), varValues(cpdVarInd), cpdVarTypes, values);

    % G

    cpdVarInd = [3 7];
    cpdVarTypes = [e r];
    values = reshape([0.8 0.1 0.2 0.9], [2 2]);
    
    cpd{7} = tabcpd(varNames(cpdVarInd), varValues(cpdVarInd), cpdVarTypes, values);

    % H

    cpdVarInd = [5 7 8];
    cpdVarTypes = [e e r];
    values = reshape([0.05 0.95 0.95 0.95 0.95 0.05 0.05 0.05], [2 2 2]);
    values = permute(values, [2 1 3]);
    
    cpd{8} = tabcpd(varNames(cpdVarInd), varValues(cpdVarInd), cpdVarTypes, values);

    Obj.bayesNet = bayesnet(structure, cpd);
    
    Obj.evidence = cell(1, 8);
    
    Obj.evidence{1} = tabpotential({'A'}, varValues(1), [1; 1]);
    Obj.evidence{2} = tabpotential({'B'}, varValues(2), [1; 1]);
    Obj.evidence{3} = tabpotential({'C'}, varValues(3), [1; 1]);
    Obj.evidence{4} = tabpotential({'D'}, varValues(4), [1; 1]);
    Obj.evidence{5} = tabpotential({'E'}, varValues(5), [1; 1]);
    Obj.evidence{6} = tabpotential({'F'}, varValues(6), [1; 1]);
    Obj.evidence{7} = tabpotential({'G'}, varValues(7), [1; 1]);
    Obj.evidence{8} = tabpotential({'H'}, varValues(8), [1; 1]);

end

function testmarginal(Obj)
   
    clc;
    
    import org.mensxmachina.pgm.bn.inference.jtree.jtreeinfengine;
    
    jTree = jtreeinfengine(Obj.bayesNet, Obj.evidence, Obj.varWeights);
    
    mpd1 = marginal(jTree, 1);
    assertElementsAlmostEqual(mpd1.values, [0.5; 0.5]);
    
    mpd4 = marginal(jTree, 4);
    assertElementsAlmostEqual(mpd4.values, [0.680; 0.320]);

end

function testwithsprinkler(Obj)
    
    
    clc;
    
    import org.mensxmachina.stats.cpd.tabular.*;    
    import org.mensxmachina.pgm.bn.inference.jtree.jtreeinfengine;
    
    bayesNet = org.mensxmachina.pgm.bn.tabular.sprinkler;
    
    varWeights = [2 2 2 2];

    e = {[1; 1], [1; 1], [1; 1], [0; 1]};
    
    domain = nominal([1; 2], {'false', 'true'}, [1 2]);
    
    evidence = cell(1, 4);
    
    evidence{1} = tabpotential({'cloudy'}, {domain}, [1; 1]);
    evidence{2} = tabpotential({'sprinkler'}, {domain}, [1; 1]);
    evidence{3} = tabpotential({'rain'}, {domain}, [1; 1]);
    evidence{4} = tabpotential({'wetGrass'}, {domain}, [0; 1]);    
    
    jTree = jtreeinfengine(bayesNet, evidence, varWeights);
    
    mpd2 = marginal(jTree, 2);
    assertElementsAlmostEqual(mpd2.values, [0.57024; 0.42976], 'absolute', 1e-5); 

    e = {[1; 1], [1; 1], [0; 1], [0; 1]};
    
    evidence{1} = tabpotential({'cloudy'}, {domain}, [1; 1]);
    evidence{2} = tabpotential({'sprinkler'}, {domain}, [1; 1]);
    evidence{3} = tabpotential({'rain'}, {domain}, [0; 1]);
    evidence{4} = tabpotential({'wetGrass'}, {domain}, [0; 1]); 
    
    jTree.evidence = evidence;
    %jTree = org.mensxmachina.pgm.bn.inference.jtree.jtreeinfengine(bayesNet, e);
    
    mpd2 = marginal(jTree, 2);

    assertElementsAlmostEqual(mpd2.values, [0.8055; 0.1945], 'absolute', 1e-5);  
    
end

end

end