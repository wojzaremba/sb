classdef errormtpapplier < org.mensxmachina.stats.mt.mtp.mtpapplier
%ERRORMTPAPPLIER Error-estimating-multiple-testing-procedure applier.
%   ORG.MENSXMACHINA.STATS.MT.MTP.ERROR.ERRORMTPAPPLIER is the class of
%   error-estimating-multiple-testing-procedure (error-MTP) appliers. An
%   error-MTP applier uses a multiple-testing-error estimator to estimate
%   the error at each p-value and then thresholds at the maximal p-value
%   with corresponding error <= to an error threshold.

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

% References:
%  [1] J.D. Storey, J.E. Taylor and D. Siegmund. "Strong control,
%      conservative point estimation, and simultaneous conservative
%      consistency of false discovery rates: A unified approach", Journal
%      of the Royal Statistical Society, B (2004), 66, pp. 187-205.
%  [2] Y. Benjamini and Y. Hochberg. Controlling the false discovery
%      rate: A practical and powerful approach to multiple testing. Journal
%      of the Royal Statistical Society. Series B (Methodological),
%      57(1):pp. 289-300, 1995.

properties(SetAccess = immutable)
    
nHypotheses % number of hypotheses -- a nonnegative integer
ErrorEstimator % multiple-testing-error estimator
errorThreshold % multiple-testing-error threshold -- a numeric real scalar

end

methods

% constructor

function Obj = errormtpapplier(ErrorEstimator, errorThreshold)
%ERRORMTPAPPLIER Create error-estimating-multiple-testing-procedure applier.
%   SUMPTAPPLIEROBJ =
%   ORG.MENSXMACHINA.STATS.MT.MTP.ERROR.ERRORMTPAPPLIER(M, EEOBJ,
%   ERRORTHRESHOLD) creates a error-estimating-multiple-testing-procedure
%   applier with multiple-testing-error estimator EEOBJ and error threshold
%   ERRORTHRESHOLD. ERRORTHRESHOLD is a non-NaN numeric real scalar.

    % parse input
    assert(isa(ErrorEstimator, 'org.mensxmachina.stats.mt.error.errorestimator'));
    validateattributes(errorThreshold, {'numeric'}, {'real', 'scalar', 'nonnan'});
    
    % set properties
    Obj.nHypotheses = ErrorEstimator.nHypotheses;
    Obj.ErrorEstimator = ErrorEstimator;
    Obj.errorThreshold = errorThreshold;

end

end

methods

% abstract method implementations

function t = mtpthreshold(Obj, p)
    
    % estimate error at each p-value
    error = estimateerror(Obj.ErrorEstimator, p, p);

    % sort p-values and corresponding errors
    [sortedP pOrder] = sort(p);
    sortedPError = error(pOrder);
    
    t = sortedP(find(sortedPError <= Obj.errorThreshold, 1, 'last'));
    
    if isempty(t)
        t = -1;
    end

end

end

end