classdef infengine < handle
%INFENGINE Inference engine.
%   ORG.MENSXMACHINA.STATS.CPD.INFERENCE.INFENGINE is the abstract class of
%   inference engines. An inference engine can compute the marginal
%   probability distribution of any member of some set of variables.

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

properties(Abstract)
    
evidence % evidence -- an 1-by-M cell array of likelihoods
    
end

properties(Abstract, SetAccess = immutable)
    
nVars % number of variables -- a numeric nonnegative integer
    
end

methods(Abstract)

%MARGINAL Marginal probability distribution.
%   M = MARGINAL(ENGINE, X) computes the marginal probability distribution
%   of variable X in inference engine ENGINE. X is the linear index of a
%   variable in ENGINE. M is a conditional probability distribution with
%   X as the sole response variable and no explanatory variables.
m = marginal(Obj, x)

end

end