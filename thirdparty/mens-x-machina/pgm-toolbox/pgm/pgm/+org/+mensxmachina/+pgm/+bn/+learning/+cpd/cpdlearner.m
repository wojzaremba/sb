classdef cpdlearner < handle
%CPDLEARNER Conditional-probability-distribution learner.
%   ORG.MENSXMACHINA.PGM.BN.LEARNING.CPD.CPDLEARNER is the abstract class
%   of conditional-probability-distribution learners. A
%   conditional-probability-distribution learner learns the conditional
%   probability distributions corresponding to a Bayesian network
%   structure.

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

properties(Abstract, SetAccess = immutable)
    
varNames % variable names -- an 1-by-M cell array of strings   
    
structure % structure -- an M-by-M sparse matrix representing a DAG
    
end

methods(Abstract)
    
%LEARNCPD Learn conditional probability distributions.
%   CPD = LEARNCPD(L) runs conditional-probability-distribution learner L.
%   CPD is an 1-by-M cell array of conditional probability distributions,
%   where M is the number of variables in L. Each cell of CPD contains the
%   conditional probability distribution of the corresponding variable
%   given values of its parents in L structure.
cpd = learncpd(Obj);

end

end