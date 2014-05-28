classdef(Sealed) fishersztestpvalueestimator < org.mensxmachina.stats.tests.ci.citpvalueestimator
%FISHERSZTESTPVALUEESTIMATOR Fisher's-Z-test-of-conditional-independence-p-value estimator.
%   ORG.MENSXMACHINA.STATS.TESTS.CI.FISHERSZ.FISHERSZTESTPVALUEESTIMATOR is
%   the class of Fisher's-Z-test-of-conditional-independence-p-value
%   estimators.

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

properties(SetAccess = immutable)
    
nVars % number of variables -- a numeric nonnegative integer
    
end

properties(GetAccess = private, SetAccess = immutable)
    
sample % sample -- an M-by-N numeric matrix of positive integers

end

methods
    
function Obj = fishersztestpvalueestimator(sample)
%FISHERSZTESTPVALUEESTIMATOR Create Fisher's-Z-test-of-conditional-independence-p-value estimator.
%   OBJ =
%   ORG.MENSXMACHINA.STATS.TESTS.CI.FISHERSZ.FISHERSZTESTPVALUEESTIMATOR(SAMPLE)
%   creates a Fisher's-Z-test-of-conditional-independence-p-value estimator
%   with sample SAMPLE. SAMPLE is an M-by-N numeric real matrix, where M is
%   the number of observations and N is the number of variables in the
%   sample. Each element of SAMPLE is the value of the corresponding
%   variable for the corresponding observation.
    
    % parse input
    validateattributes(sample, {'numeric'}, {'2d', 'real'});
    
    % set properties
    Obj.nVars = size(sample, 2);
    Obj.sample = sample;
    
end
    
end

methods

% abstract method implementations

function [p stat] = citpvalue(Obj, i, j, k)
    
    % (no validation)
    ind = [i j k];

    % select test variables
    varSample = Obj.sample(:, ind);
    
    % varSample size
    n = size(varSample, 1);

    % conditioning set size
    ns = size(varSample, 2) - 2;

    % compute varSample linear partial correlation coefficient
    r = partialcorr(varSample(:, 1), varSample(:, 2), varSample(:, 3:end));

    % compute Fisher's Z statistic
    stat = (sqrt(n - ns - 3)*log((1 + r)/(1 - r)))/2;

    % compute p-value
    p = 2*normcdf(-abs(stat),0,1);

end

end

end