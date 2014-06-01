function BayesNet = dslnodes2bayesnet(Nodes)
%DSLNODES2BAYESNET Convert DSL Nodes to Bayesian network.
%   BN = ORG.MENSXMACHINA.PGM.BN.CONVERTERS.DSL.DSLNODES2BAYESNET(NODES)
%   converts the cell array of structures NODES representing a Bayesian
%   network in the Causal Explorer toolkit by the Discovery Systems
%   Laboratory (DSL) to a Bayesian network. The format of NODES is
%   described in the Causal Explorer manual. Causal Explorer can be
%   downloaded from http://www.dsl-lab.org/causal_explorer/index.html.
%
%   See also ORG.MENSXMACHINA.PGM.BN.CONVERTERS.DSL.BAYESNET2DSLNODES,
%   ORG.MENSXMACHINA.PGM.BN.BAYESNET,
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

% DSL network format:
% Nodes{i}
%         .parents = Parents of the node i
%         .cpt     = Cumulative probability table
%         .name    = Name of the node

import org.mensxmachina.array.makesize;
import org.mensxmachina.stats.cpd.cpdvartype;
import org.mensxmachina.pgm.bn.bayesnet;

assert(iscell(Nodes) && isvector(Nodes));
assert(all(cellfun(@(iNode) isstruct(iNode) && all(isfield(iNode, {'parents', 'cpt', 'name'})), Nodes))); % correct struct
assert(all(cellfun(@(iNode) isnumeric(iNode.parents) && isreal(iNode.parents) && (isvector(iNode.parents) || isempty(iNode.parents)), Nodes))); % correct parents
assert(all(cellfun(@(iNode) all(iNode.parents >= 1 & iNode.parents <= length(Nodes) & round(iNode.parents) == iNode.parents), Nodes))); % correct parent elements
assert(all(cellfun(@(iNode) isnumeric(iNode.cpt) && isreal(iNode.cpt) && ndims(iNode.cpt) == max(length(iNode.parents) + 1, 2), Nodes))); % correct CPT
assert(all(cellfun(@(iNode) ischar(iNode.name), Nodes))); % correct CPT   
    
% correct connectivity is checked in BAYESNET

numNodes = length(Nodes);
nLevels = cellfun(@(iNode) size(iNode.cpt, 1), Nodes);

% create response variable names
responseVariableNames = cellfun(@(node) {node.name}, Nodes);

% create graph and number of levels vector

row = [];
col = [];

parents = cell(1, numNodes);
cpt = cell(1, numNodes);

for i = 1 : numNodes % for each node
    
    assert(isequal(size(Nodes{i}.cpt), makesize([nLevels(i) nLevels(Nodes{i}.parents)])));
    
    if isempty(Nodes{i}.parents)
        
        parents{i} = zeros(1, 0);
        cpt{i} = Nodes{i}.cpt;
        
    else
        
        % get and sort parents
        [parents{i} order] = sort(Nodes{i}.parents);
        
        % bring child dimension to the end
        cpt{i} = shiftdim(Nodes{i}.cpt, 1);
        
        % sort parent dimensions
        cpt{i} = permute(cpt{i}, [order (length(parents{i}) + 1)]);
        
    end
    
    row = [row parents{i}];
    col = [col i*ones(1, length(parents{i}))];
    
end

% create BAYESNET arguments

structure = sparse(row, col, true, numNodes, numNodes);

% create CPT arguments

% create response variable values
responseVariableValues = arrayfun(@(iNumLevels) nominal(1:iNumLevels)', nLevels, 'UniformOutput', false);

% create variable types
varTypes = cellfun(@(iParents) [repmat(cpdvartype.Explanatory, 1, length(iParents)) cpdvartype.Response], parents, 'UniformOutput', false);

% create explanatory variable values
explanatoryVarValues = cellfun(@(iParents) responseVariableValues(iParents), parents, 'UniformOutput', false);

% create explanatory variable names
explanatoryVariableNames = cellfun(@(iParents) responseVariableNames(iParents), parents, 'UniformOutput', false);

% create CPDs
cpd = cellfun(...
    @(iVariableTypeVariableValue, iResponseVariableValue, iVariableType, iCpt, iResponseVariableName, iVariableTypeVariableName) ...
        org.mensxmachina.stats.cpd.tabular.tabcpd(...
            [iVariableTypeVariableName, {iResponseVariableName}], ...
            [iVariableTypeVariableValue {iResponseVariableValue}], iVariableType, iCpt), ...
    explanatoryVarValues, responseVariableValues, varTypes, cpt, responseVariableNames, explanatoryVariableNames, 'UniformOutput', false);

% create the network Object
BayesNet = bayesnet(structure, cpd);

end