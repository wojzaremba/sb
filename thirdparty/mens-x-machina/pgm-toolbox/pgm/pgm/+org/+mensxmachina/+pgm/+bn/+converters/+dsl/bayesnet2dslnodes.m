function Nodes = bayesnet2dslnodes(BayesNet)
%BAYESNET2DSLNODES Convert Bayesian network to DSL Nodes.
%   NODES = ORG.MENSXMACHINA.PGM.BN.CONVERTERS.DSL.BAYESNET2DSLNODES(BN)
%   converts Bayesian network BN to a cell array of structures representing
%   a Bayesian network in the Causal Explorer toolkit by the Discovery
%   Systems Laboratory (DSL). BN is a Bayesian network with tabular CPDs.
%   The format of NODES is described in the Causal Explorer manual. Causal
%   Explorer can be downloaded from
%   http://www.dsl-lab.org/causal_explorer/index.html.
%
%   Example:
%
%       import org.mensxmachina.pgm.bn.converters.dsl.bayesnet2dslnodes;
%
%       % load the Alarm network
%       load('alarm_bnet', 'BayesNet');
% 
%       % convert to DSL representation
%       Nodes = org.mensxmachina.pgm.bn.converters.dsl.bayesnet2dslnodes(BayesNet)
%
%   See also ORG.MENSXMACHINA.PGM.BN.CONVERTERS.DSL.DSLNODES2BAYESNET,
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

% parse input
assert(isa(BayesNet, 'org.mensxmachina.pgm.bn.bayesnet'));
assert(all(cellfun(@(thisCpd) isa(thisCpd, 'org.mensxmachina.stats.cpd.tabular.tabcpd'), BayesNet.cpd)));

Nodes = cell(1, length(BayesNet.varNames));

for i = 1:length(BayesNet.varNames) % for each node

    % find parents
    pa_i = find(BayesNet.structure(:, i))';
    
    cpt_i = BayesNet.cpd{i}.values; % get CPT
            
    if ~isempty(pa_i)
    
        % find index of response variable in i-th CPD
        [~, j] = ismember(BayesNet.varNames{i}, BayesNet.cpd{i}.varNames);

        % find indices of explanatory variables in i-th CPD
        [~, pa_j] = ismember(BayesNet.varNames(pa_i), BayesNet.cpd{i}.varNames);
    
        % permute CPT
        cpt_i = permute(cpt_i, [j pa_j]);
        
    end
    
    name_i = BayesNet.varNames{i};

    Nodes{i} = struct('parents', pa_i, 'cpt', cpt_i, 'name', name_i);

end

end