function BayesNet = xdslread(filename, useNodeNames)
%XDSLREAD Read Bayesian network from XDSL file.
%   BN = ORG.MENSXMACHINA.PGM.BN.IO.XDSL.XDSLREAD(FILENAME) reads a
%   Bayesian network from XDSL file FILENAME. BN is a Bayesian network with
%   tabular CPDs.
%
%   XDSL is a Bayesian network XML format used by software package GeNIe &
%   SMILE (http://genie.sis.pitt.edu/).
%
%   ORG.MENSXMACHINA.PGM.BN.IO.XDSL.XDSLREAD uses the CPT IDs in the XDSL
%   file as the variable names and the state IDs as the level labels.
%
%   BN = ORG.MENSXMACHINA.PGM.BN.IO.XDSL.XDSLREAD(FILENAME, USENODENAMES)
%   uses the node names in the XDSL file as the variable names if
%   USENODENAMES is true and the CPT IDs otherwise. USENODENAMES is a
%   logical scalar.

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

% References:
%   [1] http://genie.sis.pitt.edu/wiki/Appendices:_XDSL_File_Format_-_XML_Schema_Definitions

import org.mensxmachina.array.makesize;
import org.mensxmachina.stats.cpd.tabular.maketabcpdvalues;
import org.mensxmachina.stats.cpd.cpdvartype;
import org.mensxmachina.pgm.bn.bayesnet;

if nargin < 2
    useNodeNames = false;
else
    validateattributes(useNodeNames, {'logical'}, {'scalar'});
end

% open XDSL file
xDoc = xmlread(filename);

% get smile nodes
smileNodes = xDoc.getElementsByTagName('smile');

if smileNodes.getLength > 0 % there are smile nodes

    firstSmileNode = smileNodes.item(0); % get the first one
    
    % get cpt nodes in the smile node
    cptNodes = firstSmileNode.getElementsByTagName('cpt');
    numCptNodes = cptNodes.getLength;
    
    cpt = struct( ...
        'id', {cell(1, numCptNodes)}, ...
        'state', {cell(1, numCptNodes)}, ...
        'parents', {cell(1, numCptNodes)}, ...
        'probabilities', {cell(1, numCptNodes)} ...
        );

    for i = 1:numCptNodes % for each cpt node in the smile node

        cptNode = cptNodes.item(i-1);

        cpt.id{i} = char(cptNode.getAttribute('id'));

        stateNodes = cptNode.getElementsByTagName('state');
        numStateNodes = stateNodes.getLength;

        cpt.state{i} = struct('id', {cell(1, numStateNodes)}, 'label', {cell(1, numStateNodes)});
        cpt.state{i} = struct('id', {cell(1, numStateNodes)});

        for j = 1:numStateNodes % for each state node in the cpt node

            stateNode = stateNodes.item(j-1);

            % get state id
            cpt.state{i}.id{j} = char(stateNode.getAttribute('id'));

            if stateNode.hasAttribute('label')
                cpt.state{i}.label{j} = char(stateNode.getAttribute('label'));
            else
                % set state id as the label too
                cpt.state{i}.label{j} = cpt.state{i}.id{j};
            end

        end

        parentsNodes = cptNode.getElementsByTagName('parents');
        numParentsNodes = parentsNodes.getLength;

        if numParentsNodes > 0
            lastParentsNode = parentsNodes.item(numParentsNodes-1);
            cpt.parents{i} = regexp(char(lastParentsNode.getFirstChild.getData), ' ', 'split');
        else % root node
            cpt.parents{i} = cell(1, 0);
        end
        
        probabilitiesNodes = cptNode.getElementsByTagName('probabilities');
        probabilitiesNode = probabilitiesNodes.item(0);

        cpt.probabilities{i} = str2num(char(probabilitiesNode.getFirstChild.getData));

    end
    
    % get node nodes in the smile node 
    % (actually, inside the extensions node)
    nodeNodes = firstSmileNode.getElementsByTagName('node');
    numNodeNodes = nodeNodes.getLength;
    
    node = struct( ...
        'id', {cell(1, numCptNodes)}, ...
        'name', {cell(1, numCptNodes)} ...
        );

    for i = 1:numNodeNodes % for each node node in the smile node

        nodeNode = nodeNodes.item(i-1);

        node.id{i} = char(nodeNode.getAttribute('id'));
        
        nameNodes = nodeNode.getElementsByTagName('name');
        nameNode = nameNodes.item(0);
        
        node.name{i} = char(nameNode.getFirstChild.getData);
        
    end
    
    % create BAYESNET arguments
    
    nLevels = zeros(1, numCptNodes);
    levelLabel = cell(1, numCptNodes);
    
    parents = cell(1, numCptNodes);
    edgeFrom = [];
    edgeTo = [];
    
    cpt_out = cell(1, numCptNodes);
    
    responseVariableName = cell(1, numCptNodes);
    
    for i = 1:numCptNodes % for each cpt
        
        % assign the number of states to the number of levels
        nLevels(i) = length(cpt.state{i}.id);
        
        % assign state labels to the level labels
        levelLabel{i} = cpt.state{i}.label;
        
        % store the parent global indices
        parents{i} = arrayfun(@(thisCptParent) find(strcmp(thisCptParent, cpt.id), 1), cpt.parents{i});
            
        % store the edges
        edgeFrom = [edgeFrom parents{i}];
        edgeTo = [edgeTo repmat(i, 1, length(parents{i}))];
        
        % find index of cpt in node
        nodeIndInNode = find( strcmp(cpt.id{i}, node.id), 1);
        
        if useNodeNames
            % assign node name to the variable name
            responseVariableName{i} = genvarname(node.name{nodeIndInNode});
        else
            % assign cpt id to the variable name
            responseVariableName{i} = cpt.id{i};
        end
        
        cpt_out{i} = reshape(cpt.probabilities{i}, makesize([nLevels(i) nLevels(parents{i}(end:-1:1))])); 
        
        if ~isempty(parents{i})
            
            cpt_out{i} = shiftdim(cpt_out{i}, 1);
            parents{i} = parents{i}(end:-1:1);
            
            % sort parents
            [parents{i} order] = sort(parents{i});
        
            % sort parent dimensions
            cpt_out{i} = permute(cpt_out{i}, [order (length(parents{i}) + 1)]);
            
        end
        
        cpt_out{i} = maketabcpdvalues([repmat(cpdvartype.Explanatory, 1, length(parents{i})) cpdvartype.Response], cpt_out{i});
        
    end
    
    if length(unique(responseVariableName)) < length(responseVariableName) % there are duplicate node names
        
        % assign cpt ids to the variable names
        responseVariableName = cpt.id;
        
    end
    
    % create structure
    structure = sparse(edgeFrom, edgeTo, true, numCptNodes, numCptNodes);
    
    % create CPT arguments

    % create response variable values
    responseVariableValue = cellfun(@(iLevelLabel) nominal(1:length(iLevelLabel), iLevelLabel)', levelLabel, 'UniformOutput', false);

    % create explanatory variable values
    explanatoryVarValues = cellfun(@(iParents) responseVariableValue(iParents), parents, 'UniformOutput', false);

    % create variable types
    varTypes = cellfun(@(iParent) [repmat(cpdvartype.Explanatory, 1, length(iParent)) cpdvartype.Response], parents, 'UniformOutput', false);
    
    % create explanatory variable names
    explanatoryVariableName = cellfun(@(iParents) responseVariableName(iParents), parents, 'UniformOutput', false);
    
    % create CPDs
    cpd_bnet = cellfun(...
        @(iExplanatoryVariableValue, iResponseVariableValue, iVariableType, iCpt, iResponseVariableName, iExplanatoryVariableName) ...
            org.mensxmachina.stats.cpd.tabular.tabcpd(...
                [iExplanatoryVariableName {iResponseVariableName}], ...
                [iExplanatoryVariableValue, {iResponseVariableValue}], ...
                iVariableType, iCpt), ...
        explanatoryVarValues, responseVariableValue, varTypes, cpt_out, responseVariableName, explanatoryVariableName, 'UniformOutput', false);

    % create the network Object 
    BayesNet = bayesnet(structure, cpd_bnet);
    
else
    
    error('There are no networks in the file!');
    
end

end