function BayesNet = bifread(filename)
%BIFREAD Read Bayesian network from BIF file.
%   BN = ORG.MENSXMACHINA.PGM.BN.IO.BIF.BIFREAD(FILENAME) reads a Bayesian
%   network from BIF file FILENAME. BN is a Bayesian network with tabular
%   CPDs.
%
%   ORG.MENSXMACHINA.PGM.BN.IO.BIF.BIFREAD calls the web service at
%   http://www.digitas.harvard.edu/cgi-bin/ken/bif2bnt in order to read the
%   file, so the computer must be connected to the Internet.
%
%   Example:
%
%       import org.mensxmachina.pgm.bn.io.bif.bifread;
%
%       % assuming file alarm.bif is on the path
%       bnet = bifread('alarm.bif');
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

import org.mensxmachina.pgm.bn.bayesnet;
import org.mensxmachina.array.makesize;
import org.mensxmachina.stats.cpd.cpdvartype;
import org.mensxmachina.stats.cpd.tabular.maketabcpdvalues;

dot_pos = strfind(filename, '.');
last_dot_pos = dot_pos(end);

% determine the filename of the cached BNT code
cache_filename = [filename(1:last_dot_pos-1) '_bifread_cache.txt' ];

if exist(cache_filename, 'file')
    
    % read BNT code from cache
    bnt_code = fileread(cache_filename);
    
else % call the web service
    
    % open BIF file
    bif = fileread(filename);

    % get BNT code
    bnt_code = urlread( ...
        'http://www.digitas.harvard.edu/cgi-bin/ken/bif2bnt', 'post', ...
        {'bif_textarea', bif} );

    % cache it
    fid = fopen(cache_filename, 'w');
    fwrite(fid, bnt_code);
    fclose(fid);
    
end

% evaluate the code
eval(bnt_code);

% create response variable names
responseVariableName = fieldnames(node)';

% get number of nodes
numNodes = size(bnet.dag, 1);

% get node sizes from the BNT network struct
nLevels = bnet.node_sizes;

% get parents of each node
parent = arrayfun(@(i) find(bnet.dag(:, i))', 1:numNodes, 'UniformOutput', false);

cpt = cell(1, numNodes);

for i = 1:size(bnet.dag, 1)

    cpt{i} = get_field(bnet.CPD{i}, 'cpt');

    % reshape into table
    cpt{i} = reshape(cpt{i}, makesize([nLevels(parent{i}) nLevels(i)]));
    
    % normalize
    cpt{i} = maketabcpdvalues([repmat(cpdvartype.Explanatory, 1, length(parent{i})) cpdvartype.Response], cpt{i});
    
end

% create BAYESNET arguments

% create structure
dag = sparse(logical(bnet.dag));

% create CPT arguments

% create response variable values
responseVariableValue = cellfun(@(iValue) nominal(1:length(iValue), iValue)', value, 'UniformOutput', false);

% create explanatory variable values
explanatoryVarValues = cellfun(@(pa_i) responseVariableValue(pa_i), parent, 'UniformOutput', false);

% create variable types
varTypes = cellfun(@(iParent) [repmat(cpdvartype.Explanatory, 1, length(iParent)) cpdvartype.Response], parent, 'UniformOutput', false);

% create explanatory variable names
explanatoryVariableName = cellfun(@(pa_i) responseVariableName(pa_i), parent, 'UniformOutput', false);

% create CPDs
cpd_bnet = cellfun(...
    @(iExplanatoryVariableValue, iResponseVariableValue, iVariableType, iCpt, iResponseVariableName, iExplanatoryVariableName) ...
        org.mensxmachina.stats.cpd.tabular.tabcpd(...
            [iExplanatoryVariableName {iResponseVariableName}], ...
            [iExplanatoryVariableValue {iResponseVariableValue}], ...
            iVariableType, iCpt), ...
    explanatoryVarValues, responseVariableValue, varTypes, cpt, responseVariableName, explanatoryVariableName, 'UniformOutput', false);
    
% create the network Object 
BayesNet = bayesnet(dag, cpd_bnet);

end

% dummy functions to emulate BNT Objects creation
% without adding BNT to path

function bnet = mk_bnet(dag, node_sizes)
% TABULAR_CPD emulates the BNT mk_bnet() function
% Instead of a BNT network struct, it returns a struct
% with the 'dag', 'node_sizes' and 'CPD' fields only.

bnet.dag = dag;
bnet.node_sizes = node_sizes(:)';
bnet.CPD = cell(1, numel(node_sizes));

end

function CPD = tabular_CPD(bnet, self, cpt)
% TABULAR_CPD emulates the constructor of a BNT tabular_CPD class
% Instead of a tabular_CPD Object, it returns a struct
% with the 'cpt' field only.

CPD.cpt = cpt;

end

function value = get_field(CPD, fieldname)
    value = CPD.(fieldname);
end