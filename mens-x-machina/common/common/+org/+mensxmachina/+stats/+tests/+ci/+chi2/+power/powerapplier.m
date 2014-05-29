classdef(Sealed) powerapplier < org.mensxmachina.stats.tests.ci.citrcapplier
%POWERAPPLIER POWER applier.
%   ORG.MENSXMACHINA.STATS.TESTS.CI.CHI2.POWER.POWERAPPLIER is the class of
%   POWER appliers. POWER is a reliability criterion for Chi-square tests
%   of conditional independence. According to this criterion, a test is
%   reliable if its power exceeds a threshold.

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
    
nObs % number of observations -- a numeric positive integer

varNValues % variable numbers of values -- an 1-by-N numeric vector of positive integers

dfThreshold % Degrees-of-freedom threshold

end

methods

% constructor

function Obj = powerapplier(varNValues, nObs, w, varargin)
%POWERAPPLIER POWER applier.
%   OBJ =
%   ORG.MENSXMACHINA.STATS.TESTS.CI.CHI2.POWER.POWERAPPLIER(VARNVALUES,
%   NOBS, W) creates a POWER applier with variable numbers of values
%   VARNVALUES, number of observations (sample size) NOBS and effect size
%   W. VARNVALUES is an 1-by-N numeric vector of positive integers. Each
%   element of VARNVALUES is the number of values of the corresponding
%   variable. W is a numeric real scalar in range [0, 1].
%
%   OBJ =
%   ORG.MENSXMACHINA.STATS.TESTS.CI.CHI2.POWER.POWERAPPLIER(VARNVALUES,
%   NOBS, W, 'Param1', VAL1, 'Param2', VAL2, ...) specifies additional
%   parameter name/value pairs chosen from the following:
%
%   'type1ErrorRate'    Type I error rate -- a numeric real scalar in range
%                       [0, 1]. Default is 0.05.
%
%   'type2ErrorRate'    Type II error rate -- a numeric real scalar in
%                       range [0, 1]. Default is 0.05.

    import org.mensxmachina.stats.array.*;

    ip = inputParser;

    ip.addRequired('varNValues', @(a) validateattributes(a, {'numeric'}, {'row', '>=', 1, 'integer'}));    
    ip.addRequired('nObs', @(a) validateattributes(a, {'numeric'}, {'scalar', 'positive', 'integer'}));    
    ip.addRequired('w', @(a) validateattributes(a, {'numeric'}, {'real', 'scalar', '>=', 0, '<=', 1}));

    ip.addParamValue('type1ErrorRate', 0.05, @(a) validateattributes(a, {'numeric'}, {'real', 'scalar', '>=', 0, '<=', 1}));
    ip.addParamValue('type2ErrorRate', 0.05, @(a) validateattributes(a, {'numeric'}, {'real', 'scalar', '>=', 0, '<=', 1}));

    ip.parse(varNValues, nObs, w, varargin{:});
    
    type1ErrorRate = ip.Results.type1ErrorRate;
    type2ErrorRate = ip.Results.type2ErrorRate;
    
    % set properties
    Obj.nVars = length(varNValues);
    Obj.nObs = nObs;
    Obj.varNValues = varNValues;
    Obj.dfThreshold = kdl.bayes.util.StatUtil.dofThresholdForEffect(Obj.nObs, w, 1 - type2ErrorRate, type1ErrorRate);

end

end

methods

% abstract method implementations

function tf = isreliablecit(Obj, i, j, k)
    
    % (no validation)
    
    % get test variable numbers of values
    testVarNValues = Obj.varNValues([i j k]);

    % compute *traditional* degrees of freedom
    df = (testVarNValues(1) - 1)*(testVarNValues(2) - 1)*prod(testVarNValues(3:end));

    tf = df <= Obj.dfThreshold; % in Fast'k code is <, it should be <= though

end

function wmk = worstmaxcondsetcard(Obj, i, j, k)
    
    % (no validation)
    
    wmk = maxk(Obj, i, j, k, 'descend');
    
end

function bmk = bestmaxcondsetcard(Obj, i, j, k)
    
    % (no validation)
    
    bmk = maxk(Obj, i, j, k, 'ascend');
    
end

end

methods(Access = private)  

function maxk = maxk(Obj, i, j, k, sNValuesSortMode)
    
    % get number of values for each test variable
    xNValues = Obj.testVarNValues(i);
    yNValues = Obj.testVarNValues(j);
    sNValues = Obj.testVarNValues(k);  
    
    testVarNValues = [xNValues yNValues sort(sNValues, sNValuesSortMode)];   

    maxmaxk = length(testVarNValues) - 2;

    % (TESTVARNVALUES(1) - 1)*(TESTVARNVALUES(2) - 1)*PROD(TESTVARNVALUES(1:K)) <= DFTHRESHOLD solved for K

    maxk = 0;

    while maxk <= maxmaxk && (testVarNValues(1) - 1)*(testVarNValues(2) - 1)*prod(testVarNValues(1:maxk)) <= Obj.dfThreshold
        maxk = maxk + 1;
    end

    maxk = maxk - 1;

    if maxk < 0
        maxk = NaN;
    end            

end

end

end