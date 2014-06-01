classdef(Sealed) thumbapplier < org.mensxmachina.stats.tests.ci.citrcapplier
%THUMBAPPLIER Rule-of-thumb applier.
%   ORG.MENSXMACHINA.STATS.TESTS.CI.CHI2.THUMB.THUMBAPPLIER is the class of
%   rule-of-thumb appliers. Rule of thumb is a reliability criterion for
%   Chi-square tests of conditional independence. According to this
%   criterion, a test is reliable if there are at least T observations, on
%   average, for each degree of freedom of the test.

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
% [1] A.S. Fast. Learning the structure of Bayesian Networks with
%     Constraint Satisfaction. PhD thesis, University of Massachusetts
%     Amherst, 2010.

properties(SetAccess = immutable)
    
nVars % number of variables -- a numeric positive integer
    
end

properties(GetAccess = private, SetAccess = immutable)
    
sample % sample -- an M-by-N numeric matrix of positive integers

varNValues % variable numbers of values -- an 1-by-N numeric vector of positive integers

threshold % threshold -- a numeric nonnegative integer

end

methods

% constructor

function Obj = thumbapplier(sample, varNValues, threshold)
%THUMBAPPLIER Create rule-of-thumb applier.
%   OBJ = ORG.MENSXMACHINA.STATS.TESTS.CI.CHI2.THUMB.THUMBAPPLIER(SAMPLE,
%   VARNVALUES) creates a rule-of-thumb applier with sample SAMPLE,
%   variable numbers of values VARNVALUES and threshold 5. SAMPLE is an
%   M-by-N numeric matrix of positive integers, where M is the number of
%   observations and N is the number of variables in the sample. Each
%   element of SAMPLE is the linear index of the value of the corresponding
%   variable for the corresponding observation. VARNVALUES is an 1-by-N
%   numeric vector of positive integers. Each element of VARNVALUES is the
%   number of values of the corresponding variable.
%
%   OBJ = ORG.MENSXMACHINA.STATS.TESTS.CI.CHI2.THUMB.THUMBAPPLIER(SAMPLE,
%   VARNVALUES, T) sets the threshold to T. T is a numeric nonnegative
%   integer.

    % parse input
    validateattributes(sample, {'numeric'}, {'2d', 'positive', 'integer'});
    validateattributes(varNValues, {'numeric'}, {'size', [1 size(sample, 2)], 'positive', 'integer'});    
    
    if nargin < 3
        threshold = 5;
    else
        parseattributes(threshold, {'numeric'}, {'scalar', 'nonnegative', 'integer'})
    end
    
    % set properties
    Obj.nVars = length(size(sample, 2));
    Obj.sample = sample;
    Obj.varNValues = varNValues;
    Obj.threshold = threshold;

end

end

methods

% abstract method implementations

function tf = isreliablecit(Obj, i, j, k)
    
    % (no validation)
    
    sampleSize = size(Obj.sample, 1);
    
    testVarInd = [i j k];
    
    % select test variables
    testSample = Obj.sample(:, testVarInd);
    testNLevels = Obj.varNValues(:, testVarInd);

    % compute observed level combination counts
    Obs = accumarray(testSample, ones(1, sampleSize), testNLevels);

    % Obs_xs(i,j,kk{:}): observed count of (i,kk{:}), same for all j
    ObsSum2 = sum(Obs, 2); % sum for all levels of j

    % Obs_ys(i,j,kk{:}): observed count of (j,kk{:}), same for all i
    ObsSum1 = sum(Obs, 1); % sum for all levels of i

    j3NLevelsProd = prod(testNLevels(3:end));

    ObsSum1 = reshape(ObsSum1, testNLevels(2), j3NLevelsProd);
    ObsSum2 = reshape(ObsSum2, testNLevels(1), j3NLevelsProd);

    % compute degrees of freedom
    df = 0;
    for iComb = 1:j3NLevelsProd
        df = df + max(testNLevels(1) - 1 - sum(~ObsSum2(:,iComb)), 0) * max(testNLevels(2) - 1 - sum(~ObsSum1(:,iComb)), 0);
    end

    tf = sampleSize/df >= Obj.threshold; % in Fast's code is >, it should be >= though
    
end

function wmk = worstmaxcondsetcard(~, ~, ~, ~)
    
    % (no validation)
    
    wmk = NaN;
    
end

function bmk = bestmaxcondsetcard(~, i, j, ind)
    
    % (no validation)
    
    bmk = length(ind) - (2 - length(i) - length(j));
    
end

end

end