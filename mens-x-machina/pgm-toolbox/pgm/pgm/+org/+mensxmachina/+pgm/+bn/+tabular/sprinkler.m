function bnet = sprinkler
%SPRINKLER Create the example sprinkler Bayesian network.
%   BNET = ORG.MENSXMACHINA.PGM.BN.TABULAR.SPRINKLER creates the sprinkler
%   example Bayesian network from Artificial Intelligence: A Modern
%   Approach (1st Edition). BNET is a Bayesian network with tabular
%   conditional probability distributions.
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

% References:
% [1] Stuart J. Russell and Peter Norvig. Artificial intelligence: a
%     modern approach. Prentice Hall series in artificial intelligence. 
%     Prentice Hall, 1st edition, January 1995.

import org.mensxmachina.stats.cpd.cpdvartype;
import org.mensxmachina.stats.cpd.tabular.tabcpd;
import org.mensxmachina.pgm.bn.bayesnet;

% create structure
structure = sparse([1 1 2 3], [2 3 4 4], 1, 4, 4);

% create variable values
varValues = nominal([1; 2], {'false', 'true'}, [1 2]);

% create CPDs
cpd = cell(1, 4);
cpd{1} = tabcpd({'cloudy'}, {varValues}, cpdvartype.Response, reshape([0.5 0.5], 2, 1));
cpd{2} = tabcpd({'cloudy', 'sprinkler'}, {varValues, varValues}, [cpdvartype.Explanatory cpdvartype.Response], reshape([0.5 0.5; 0.9 0.1], 2, 2));
cpd{3} = tabcpd({'cloudy', 'rain'}, {varValues, varValues}, [cpdvartype.Explanatory cpdvartype.Response], reshape([0.8 0.2; 0.2 0.8], 2, 2));
cpd{4} = tabcpd({'sprinkler', 'rain', 'wetGrass'}, {varValues, varValues, varValues}, [cpdvartype.Explanatory cpdvartype.Explanatory cpdvartype.Response], reshape([1 0.1 0.1 0.01 0 0.9 0.9 0.99], 2, 2, 2));
   
% create Bayesian network
bnet = bayesnet(structure, cpd);

end