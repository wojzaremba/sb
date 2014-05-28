classdef testdslnodes2bayesnet < TestCase
    
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
    
end

methods

function Obj = testdslnodes2bayesnet(name)

    clc;

    Obj = Obj@TestCase(name);

    % create a sprinkler example network
    Obj.bayesNet = org.mensxmachina.pgm.bn.tabular.sprinkler;

end

function test(Obj)

    load insurance_bayesnet;

    dsl1 = org.mensxmachina.pgm.bn.converters.dsl.bayesnet2dslnodes(BayesNet);

    BayesNet = org.mensxmachina.pgm.bn.converters.dsl.dslnodes2bayesnet(dsl1);

    dsl2 = org.mensxmachina.pgm.bn.converters.dsl.bayesnet2dslnodes(BayesNet);

    for i = 1:length(dsl2)

        assertEqual(dsl1{i}.parents, dsl2{i}.parents);
        assertElementsAlmostEqual(dsl1{i}.cpt, dsl2{i}.cpt);
        assertEqual(dsl1{i}.name, dsl2{i}.name);

    end

end

end

end