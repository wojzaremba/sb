classdef bayesnetviewer < handle
%BAYESNETVIEWER Bayesian-network viewer.
%   ORG.MENSXMACHINA.PGM.BN.VIEWERS.BAYESNETVIEWER is the abstract class of
%   Bayesian network viewers. A Bayesian-network viewer views a Bayesian
%   network, the structure of the network, as well as its skeleton.

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

methods(Abstract)

% abstract methods

%VIEWBAYESNET View Bayesian network.
%   VIEWBAYESNET(V) views the Bayesian network of Bayesian-network viewer
%   V.
viewbayesnet(Obj);

%VIEWBAYESNETSTRUCTURE View Bayesian network structure.
%   VIEWBAYESNETSTRUCTURE(V) views the structure of the Bayesian network of
%   Bayesian-network viewer V.
viewbayesnetstructure(Obj);

%VIEWBAYESNETSKELETON View Bayesian network skeleton.
%   VIEWBAYESNETSKELETON(V) views the skeleton of the Bayesian network of
%   Bayesian-network viewer V.
viewbayesnetskeleton(Obj);

end

end