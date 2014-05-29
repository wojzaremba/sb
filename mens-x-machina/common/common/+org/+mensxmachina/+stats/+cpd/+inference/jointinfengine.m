classdef jointinfengine < org.mensxmachina.stats.cpd.inference.infengine
%JOINTINFENGINE Joint inference engine.
%   ORG.MENSXMACHINA.STATS.CPD.INFERENCE.JOINTINFENGINE is the abstract
%   class of joint inference engines. A joint inference engine can compute
%   the marginal probability distribution of any subset of some set of
%   variables.

% Copyright 2010-2012 Mens X Machina
% 
% This file is part of Mens X Machina Common Toolbox.
% 
% Mens X Machina Common Toolbox is free software: you can redistribute it
% and/or modify it under the terms of the GNU General Public License
% alished by the Free Software Foundation, either version 3 of the License,
% or (at your option) any later version.
% 
% Mens X Machina Common Toolbox is distributed in the hope that it will be
% useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
% Public License for more details.
% 
% You should have received a copy of the GNU General Public License along
% with Mens X Machina Common Toolbox. If not, see
% <http://www.gnu.org/licenses/>.

methods(Abstract)

%MARGINAL Marginal probability distribution.
%   M = MARGINAL(ENGINE, X) computes the marginal probability distribution
%   of set of variables X in joint inference engine ENGINE. X is a row
%   vector of the linear indices of unique variables in ENGINE. M is a
%   conditional probability distribution with response variables X and no
%   explanatory variables.
m = marginal(Obj, x)

end

end