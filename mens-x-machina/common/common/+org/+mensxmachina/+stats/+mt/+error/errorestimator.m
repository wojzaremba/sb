classdef errorestimator < handle
%ERRORESTIMATOR Multiple-testing-error estimator.
%   ORG.MENSXMACHINA.STATS.MT.ERROR.ERRORESTIMATOR is the abstract class
%   of multiple-testing-error estimators. A multiple-testing-error
%   estimator estimates, at various p-value thresholds, a
%   multiple-testing-error for a set of hypotheses given p-values
%   corresponding to a subset of the hypotheses.

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

properties(Abstract, SetAccess = immutable)
    
nHypotheses % number of hypotheses -- a numeric real scalar
    
end

methods(Abstract)

%ESTIMATEERROR Estimate multiple-testing-error.
%   ERR = ESTIMATEERROR(ERREST, P, T), where ERREST is a
%   multiple-testing-error estimator for M hypotheses, P is a set of
%   p-values corresponding to a subset of the hypotheses and T a set of
%   p-value thresholds, estimates from P the error ERR when rejecting
%   hypotheses with corresponding p-value <= each of the thresholds T. Rest
%   p-values are assumed to be in range (MAX(T), 1]. P is an NP-by-1 (NP <=
%   M) numeric array with values in range [0, 1]. T is an NT-by-1 numeric
%   real array. ERR is an NT-by-1 numeric real array with values
%   nondecreasing with increasing corresponding p-value threshold in T.
err = estimateerror(Obj, p, t);

end

methods(Access = protected)
    
function t = parseestimateerrorinput(Obj, p, t)
%PARSEESTIMATEERRORINPUT Parse ORG.MENSXMACHINA.STATS.MT.ERROR.ERRORESTIMATOR/ESTIMATEERROR input.
%   PARSEESTIMATEERRORINPUT(ERREST, ...), when ERREST is a
%   multiple-testing-error estimator array, throws an error if its input is
%   not valid input for
%   ORG.MENSXMACHINA.STATS.MT.ERROR.ERRORESTIMATOR/ESTIMATEERROR.
%
%   See also
%   ORG.MENSXMACHINA.STATS.MT.ERROR.ERRORESTIMATOR/ESTIMATEERROR.

assert(isscalar(Obj));
validateattributes(p, {'numeric'}, {'real', 'column', 'nonnegative', '<=' 1});
assert(length(p) <= Obj.nHypotheses);
validateattributes(t, {'numeric'}, {'real', 'column'});

end
    
end

end