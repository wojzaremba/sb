classdef(Sealed) st2001fdrestimator < org.mensxmachina.stats.mt.error.fdr.lambda.lambdafdrestimator
%ST2001FDRESTIMATOR Storey and Tibshirani (2001) FDR estimator.
%   ORG.MENSXMACHINA.STATS.MT.ERROR.FDR.LAMBDA.ST2001.ST2001FDRESTIMATOR is
%   the class of Storey and Tibshirani (2001) p-value-based FDR estimators.
%   Parameter lambda specifies rejection region Gamma' = [0, lambda].

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
%   [1] J.D. Storey and R. Tibshirani. "Estimating the positive false
%       discovery rate under dependence, with applications to DNA 
%       microarrays", Technical Report 2001-18, Department of Statistics,
%       Stanford University, Stanford

properties(SetAccess = private)

nNullPValues % total number of null p-values in each simulation -- an 1-by-N numeric array
nullPValues % null p-values from each simulation -- an 1-by-N cell array of numeric column vectors
    
end

methods
    
% constructor

function Obj = st2001fdrestimator(m, m0, p0, varargin)
%ST2001FDRESTIMATOR Create Storey and Tibshirani (2001) FDR estimator.
%   ST2001FDRESTOBJ =
%   ORG.MENSXMACHINA.STATS.MT.ERROR.FDR.LAMBDA.ST2001.ST2001FDRESTIMATOR(M,
%   M0, P0) creates a Storey and Tibshirani (2001) FDR estimator for M
%   hypotheses with the total number of simulated null p-values in each
%   simulation specified by M0, simulated null p-values P0 from each
%   simulation and lambda = 0. M is a nonnegative integer. M0 is an N-by-1
%   array of integers in range [0, M], where N > 0 is the number of
%   simulations. Each element of M0 specifies the total number of simulated
%   null p-values in the corresponding simulation. P0 is an N-by-1 cell
%   array. Each cell P0{i} contains a numeric column vector with length <=
%   M0(i) and elements in range [0, 1] that specify a subset of the
%   simulated null p-values from the i-th simulation; rest simulated null
%   p-values are assumed by ESTIMATEERROR(ST2001FDRESTOBJ, P, T) to be in
%   range (MAX(T), 1].
%
%   ST2001FDRESTOBJ =
%   ORG.MENSXMACHINA.STATS.MT.ERROR.FDR.LAMBDA.ST2001.ST2001FDRESTIMATOR(M,
%   M0, P0, LAMBDA) uses lambda = LAMBDA. LAMBDA is a numeric scalar in
%   range [0, 1). Simulated null p-values not in P0 are assumed by
%   ESTIMATEERROR(ST2001FDRESTOBJ, P, T) to be in range (MAX(MAX(T),
%   LAMBDA), 1].
    
    % parse input
    validateattributes(m, {'numeric'}, {'nonnegative', 'integer'});
    validateattributes(m0, {'numeric'}, {'row', 'nonempty', 'nonnegative', '<=', m, 'integer'});
    validateattributes(p0, {'cell'}, {'size', size(m0)});
    assert(all(cellfun(@(thisM0, thisP0) isnumeric(thisP0) && isreal(thisP0) && ndims(thisP0) == 2 && size(thisP0, 1) <= thisM0 && size(thisP0, 2) == 1 && all(thisP0 >= 0 & thisP0 <= 1), num2cell(m0), p0)));
    
    % call LAMBDAFDRESTIMATOR constructor
    Obj = Obj@org.mensxmachina.stats.mt.error.fdr.lambda.lambdafdrestimator(m, varargin{:});

    % set properties
    Obj.nNullPValues = m0;
    Obj.nullPValues = p0;

end

end

methods(Access = protected)

% abstract method implementations

function y = er0t(Obj, ~, t)

    % compute E[R0(t)] from simulated p-values

    % sort thresholds

    [thresholds_sorted thresholds_order] = sort(t);

    thresholds_sorted_reversed = -thresholds_sorted(end:-1:1);
    thresholds_sorted_reversed(end + 1) = Inf;

    er0t = zeros(size(t));
    r0t = zeros(size(t));

    for i = 1 : length(Obj.nullPValues) % for each simulation

        % -t_(k) <= -t < -t_(k-1) <=> t_(k-1) < t <= t_(k)
        counts = histc(-Obj.nullPValues{i}, thresholds_sorted_reversed);

        r0t(thresholds_order) = cumsum(counts(end-1:-1:1));

        % normalize in order to obtain the count
        % if m null p-values were computed
        r0t = r0t*Obj.nHypotheses/Obj.nNullPValues(i);

        er0t = er0t + r0t;

    end

    y = er0t/length(Obj.nullPValues);
    
    % all hypotheses are rejected when rejecting hypotheses with
    % corresponding p-value <= 1
    y(t == 1) = Obj.nHypotheses;

end

function y = ew0lambda(Obj, ~)

    % compute E[W0(lambda)] = #{Obj.nullPValues > lambda}

    ew0lambda = 0;

    for i = 1 : length(Obj.nullPValues) % for each simulation

        w0lambda = sum(Obj.nullPValues{i} > Obj.lambda) + Obj.nNullPValues(i) - length(Obj.nullPValues{i});

        % normalize in order to obtain the sum
        % if m null p-values were computed
        w0lambda = w0lambda*Obj.nHypotheses/Obj.nNullPValues(i);

        ew0lambda = ew0lambda + w0lambda;

    end

    y = ew0lambda/length(Obj.nullPValues);

end

end

end