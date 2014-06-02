classdef(Sealed) biographbayesnetviewer < org.mensxmachina.pgm.bn.viewers.bayesnetviewer
%BIOGRAPHBAYESNETVIEWER Biograph-based Bayesian-network viewer.
%   ORG.MENSXMACHINA.PGM.BN.VIEWERS.BIOGRAPH.BIOGRAPHBAYESNETVIEWER is a
%   Bayesian-network viewer based on Bioinformatics Toolbox (TM) class
%   biograph.
%
%   See also BIOGRAPH.

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

properties(GetAccess = private, SetAccess = immutable)

Biograph % Bayesian network biograph
StructureBiograph % Bayesian network structure biograph
SkeletonBiograph % Bayesian network skeleton biograph

end

methods

% contructor

function Obj = biographbayesnetviewer(bnet, varargin)
%BIOGRAPHBAYESNETVIEWER Create Biograph-based Bayesian-network viewer.
%   BNV = BIOGRAPHBAYESNETVIEWER(BN) creates a Biograph-based
%   Bayesian-network viewer for Bayesian network BN.
%
%   [...] =
%   ORG.MENSXMACHINA.PGM.BN.VIEWERS.BIOGRAPH.BIOGRAPHBAYESNETVIEWER(BN,
%   'Param1', VAL1, 'Param2', VAL2, ...) specifies additional parameter
%   name/value pairs for the undelying biograph Objects chosen from the
%   following:
%
%       'LayoutType'    Layout type -- Default is 'hierarchical'.
%
%       'EdgeTextColor' Edge type -- Default is 'curved'.
%
%       'LayoutScale'   Layout scale -- Default is 1.
%
%       'EdgeTextColor' Edge text color -- Default is [0 0 0].
%
%       'EdgeFontSize'  Edge font size -- Default is 8.
%
%       'ArrowSize'     Node auto size -- Default is 8.
%
%       'NodeAutoSize'  Node auto size -- Default is 'on'.
%
%   See also ORG.MENSXMACHINA.PGM.BN.BAYESNET, BIOGRAPH.

    import org.mensxmachina.pgm.bn.viewers.biograph.biographbayesnetviewer;
    
    assert(isa(bnet, 'org.mensxmachina.pgm.bn.bayesnet'));
    
    ip = inputParser;
    
    ip.addParamValue('LayoutType', 'hierarchical');
    ip.addParamValue('EdgeType', 'curved');
    ip.addParamValue('LayoutScale', 1);
    ip.addParamValue('EdgeTextColor', [0 0 0]);
    ip.addParamValue('EdgeFontSize', 8);
    ip.addParamValue('ArrowSize', 8);
    ip.addParamValue('NodeAutoSize', 'on');

    ip.parse(varargin{:});

    Param = ip.Results;

    paramNames = fieldnames(Param)';
    paramValues = struct2cell(Param)';

    biographVarargin = cell(1, 2*length(paramNames));
    biographVarargin(1:2:end) = paramNames;
    biographVarargin(2:2:end) = paramValues;

    % set properties
    Obj.Biograph = biographbayesnetviewer.biograph(bnet, biographVarargin{:});
    Obj.StructureBiograph = biographbayesnetviewer.structurebiograph(bnet, biographVarargin{:});
    Obj.SkeletonBiograph = biographbayesnetviewer.skeletonbiograph(bnet, biographVarargin{:});

end

end

methods

function h = viewbayesnet(Obj)
%VIEWBAYESNET View Bayesian network.
%   VIEWBAYESNET(BNV), when BNV is a biograph-based Bayesian-network
%   viewer, opens a Figure window and draws the Bayesian network associated
%   with BNV.
%
%   H = VIEWBAYESNET(BNV) returns a handle to a deep copy of the biograph
%   Object representing the Bayesian network in the Figure window.
   
    h = Obj.Biograph.view();
    
end

function h = viewbayesnetstructure(Obj)
%VIEWSTRUCTURE View Bayesian network structure.
%   VIEW(BNV), when BNV is a biograph-based Bayesian-network viewer, opens
%   a Figure window and draws the structure of the Bayesian network
%   associated with BNV.
%
%   H = VIEW(BNV) returns a handle to a deep copy of the biograph Object
%   representing the structure of the Bayesian network in the Figure 
%   window.

    h = Obj.StructureBiograph.view();
    
end

function h = viewbayesnetskeleton(Obj)
%VIEWSKELETON View Bayesian network skeleton
%   VIEW(BNV), when BNV is a biograph-based Bayesian-network viewer, opens
%   a Figure window and draws the skeleton of the Bayesian network
%   associated with BNV.
%
%   H = VIEW(BNV) returns a handle to a deep copy of the biograph Object
%   representing the skeleton of the Bayesian network in the Figure window.

    h = Obj.SkeletonBiograph.view();
    
end

end

methods(Static, Access = private)

function bg = biograph(bnet, varargin)

    ind = 1:length(bnet.varNames);

    nodeDescription = arrayfun(@num2str, ind, 'UniformOutput', false);

    [row col] = find(bnet.structure);

    paramNodeInd = (length(bnet.varNames)+1):(length(bnet.varNames)*2);

    i = [row' paramNodeInd];
    j = [col' ind];

    G = sparse(i, j, 1, length(bnet.varNames)*2, length(bnet.varNames)*2, nnz(bnet.structure) + length(bnet.varNames));
    nodeId = [bnet.varNames arrayfun(@(i) sprintf('%sParam', bnet.varNames{i}), ind, 'UniformOutput', false)];

    %nodeLabel = [bnet.varNames arrayfun(@(i) sprintf('%sParam', bnet.varNames{i}), ind, 'UniformOutput', false)];    

    paramNodeLabel = cell(1, length(bnet.varNames));
    paramNodeDescription = cell(1, length(bnet.varNames));

    for j = ind % for each node

        % get values of the node
        % according to its NodeRandomParams given its parents

        % get the conditional pdf parameters of the node for each sample
        paramNodeLabel{j} = evalc('disp(bnet.cpd{j});');

        paramNodeDescription{j} = '';

    end

    nodeLabel = [bnet.varNames paramNodeLabel];
    nodeDescription = [nodeDescription paramNodeDescription];

    % create biograph
    bg = biograph(G, nodeId, varargin{:});

    set(bg.nodes, 'Shape', 'ellipse', 'Color', [1 1 1], 'LineColor', [0 0 0]);
    set(bg.edges, 'LineColor', [0 0 0]);

    for i=1:size(G, 1)
        set(bg.nodes(i), 'Label', nodeLabel{i}, 'Description', nodeDescription{i});
    end

    set(bg.nodes(paramNodeInd), 'Shape', 'box', 'LineColor', [1 1 1]);
    set(bg.edges(paramNodeInd), 'LineColor', [1 1 1]);

end

function bg = structurebiograph(bnet, varargin)

    ind = 1:length(bnet.varNames);

    nodeDescription = arrayfun(@num2str, ind, 'UniformOutput', false);

    G = bnet.structure;
    nodeId = bnet.varNames;
    nodeLabel = bnet.varNames;

    % create biograph
    bg = biograph(G, nodeId, varargin{:});

    set(bg.nodes, 'Shape', 'ellipse', 'Color', [1 1 1], 'LineColor', [0 0 0]);
    set(bg.edges, 'LineColor', [0 0 0]);

    for i=1:size(G, 1)
        set(bg.nodes(i), 'Label', nodeLabel{i}, 'Description', nodeDescription{i});
    end

end

function bg = skeletonbiograph(bnet, varargin)

    ind = 1:length(bnet.varNames);

    nodeDescription = arrayfun(@num2str, ind, 'UniformOutput', false);

    G = bnet.structure;
    nodeId = bnet.varNames;
    nodeLabel = bnet.varNames;

    % create biograph
    bg = biograph(G, nodeId, varargin{:}, 'ShowArrows', 'off');

    set(bg.nodes, 'Shape', 'ellipse', 'Color', [1 1 1], 'LineColor', [0 0 0]);
    set(bg.edges, 'LineColor', [0 0 0]);

    for i=1:size(G, 1)
        set(bg.nodes(i), 'Label', nodeLabel{i}, 'Description', nodeDescription{i});
    end

end

end

end