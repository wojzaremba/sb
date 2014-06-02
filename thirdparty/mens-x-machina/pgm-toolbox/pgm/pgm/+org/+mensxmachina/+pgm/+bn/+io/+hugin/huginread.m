function BayesNet = huginread(filename)
%HUGINREAD Read Bayesian network from HUGIN file.
%   BN = ORG.MENSXMACHINA.PGM.BN.IO.HUGIN.HUGINREAD(FILENAME) reads a
%   Bayesian network from HUGIN file FILENAME. BN is a Bayesian network
%   with tabular CPDs.
%
%   Causal Explorer must be on the path in order for
%   ORG.MENSXMACHINA.PGM.BN.IO.BIF.HUGINREAD to work. Causal Explorer can
%   be downloaded from http://www.dsl-lab.org/causal_explorer/index.html.
%
%   See also ORG.MENSXMACHINA.PGM.BN.BAYESNET,
%   ORG.MENSXMACHINA.STATS.CPD.TABULAR.TABCPD.

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

import org.mensxmachina.array.makesize;
import org.mensxmachina.stats.cpd.cpdvartype;
import org.mensxmachina.stats.cpd.tabular.maketabcpdvalues;
import org.mensxmachina.pgm.bn.converters.dsl.dslnodes2bayesnet;

% read into DSL
Nodes = hugin2dsl(filename);

% fix Nodes

nLevels = cellfun(@(iNode) size(iNode.cpt, 1), Nodes);

for i = 1:length(Nodes) % for each node
    
    if ~isempty(Nodes{i}.parents)
        
        % fix hugin2dsl bug
        
        % fix CPT
        Nodes{i}.cpt = reshape(Nodes{i}.cpt, makesize([nLevels(i) nLevels(Nodes{i}.parents(end:-1:1))]));
        
        % fix parents
        Nodes{i}.parents = Nodes{i}.parents(end:-1:1);
        
    end
    
    % normalize CPT
    Nodes{i}.cpt = maketabcpdvalues([cpdvartype.Response repmat(cpdvartype.Explanatory, 1, length(Nodes{i}.parents))], Nodes{i}.cpt);
    
end

BayesNet = dslnodes2bayesnet(Nodes);

end