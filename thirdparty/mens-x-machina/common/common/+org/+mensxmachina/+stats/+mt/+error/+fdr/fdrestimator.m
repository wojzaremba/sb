classdef fdrestimator < org.mensxmachina.stats.mt.error.errorestimator
%FDRESTIMATOR FDR estimator.
%   ORG.MENSXMACHINA.STATS.MT.ERROR.FDR.FDRESTIMATOR is the abstract class
%   of common FDR estimators.

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

% References: [1] J.D. Storey. "A direct approach to false discovery
% rates", Journal of
%     the Royal Statistical Society, B (2002), 64(3), pp.479-498.
% [2] J.D. Storey, J.E. Taylor and D. Siegmund. "Strong control,
%     conservative point estimation, and simultaneous conservative
%     consistency of false discovery rates: A unified approach", Journal of
%     the Royal Statistical Society, B (2004), 66, pp. 187-205.
% [3] J.D. Storey and R. Tibshirani. "Estimating the positive false
%     discovery rate under dependence, with applications to DNA
%     microarrays", Technical Report 2001-18, Department of Statistics,
%     Stanford University, Stanford

properties(SetAccess = immutable)
    
nHypotheses % number of hypotheses -- a numeric real scalar
    
end

methods
    
% constructor

function Obj = fdrestimator(m)
%FDRESTIMATOR Create FDR estimator.
%   FDRESTOBJ = ORG.MENSXMACHINA.STATS.MT.ERROR.FDR.FDRESTIMATOR(M) creates
%   an FDR estimator for M hypotheses. M is a nonnnegative integer.

    % parse input
    validateattributes(m, {'numeric'}, {'scalar', 'nonnegative', 'integer'});
    
    % set properties
    Obj.nHypotheses = m;

end    
    
% abstract method implementations

function fdr = estimateerror(Obj, p, t)
    
    % parse input
    parseestimateerrorinput(Obj, p, t);
    

    % compute E[R0(t)]
    er0t = Obj.er0t(p, t);
    
    
    % compute PI0
    pi0 = Obj.pi0(p);
    

    % compute R(t)

    r = zeros(size(t));
    
    % sort thresholds
    [thresholds_sorted thresholds_order] = sort(t);

    thresholds_sorted_reversed = -thresholds_sorted(end:-1:1);
    thresholds_sorted_reversed(end + 1) = Inf;

    % -t_(k) <= -t < -t_(k-1) <=> t_(k-1) < t <= t_(k)
    counts = histc(-p, thresholds_sorted_reversed);

    r(thresholds_order) = cumsum(counts(end-1:-1:1));
    
    % all hypotheses are rejected when rejecting hypotheses with
    % corresponding p-value <= 1
    r(t == 1) = Obj.nHypotheses;
    
    % compute FDR^(t)

    % FDR^(t) = PI0*E[R0(t)]/R(t) ([3], p. 5)
    fdr = pi0*er0t./r;

    % set FDR to zero where R = 0 ([1] p. 483 and [2] pp. 190, 192 but it
    % makes sense for any estimator)
    fdr(~r) = 0;

end

end

methods(Abstract, Access = protected)

% Note: Help for the following methods will be added in the future.
    
%PI0 Estimate proportion of true null hypotheses.
%   Y is a numeric scalar in (0, 1].
y = pi0(Obj, p)

%ER0T Estimate expected number of rejected hypotheses if all null hypotheses were true.
%   Y is a numeric scalar in [0, M].
y = er0t(Obj, p, t)

end

end