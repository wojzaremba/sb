classdef fixedthresholdapplier < org.mensxmachina.stats.mt.mtp.mtpapplier
%FIXEDTHRESHOLDAPPLIER Fixed-threshold applier.
%   ORG.MENSXMACHINA.STATS.MT.MTP.FIXEDTHRESHOLDAPPLIER is the class of
%   fixed-threshold appliers. A fixed-threshold applier thresholds p-values
%   at a fixed threshold.

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
    
nHypotheses % number of hypotheses -- a nonnegative integer
threshold % threshold -- a numeric real scalar

end

methods
    
% constructor

function Obj = fixedthresholdapplier(nHypotheses, threshold)
%FIXEDTHRESHOLDAPPLIER Create fixed-threshold applier.
%   A =
%   ORG.MENSXMACHINA.STATS.MT.MTP.FIXEDTHRESHOLDAPPLIER(M,
%   T) creates a fixed-threshold applier for M hypotheses and threshold T.
%   M is a nonnnegative integer. T is a numeric scalar in range [0, 1].

    % parse input
    validateattributes(nHypotheses, {'numeric'}, {'nonnegative', 'integer'});
    validateattributes(threshold, {'numeric'}, {'real', 'scalar', 'nonnegative', '<=', 1});
    
    % set properties
    Obj.nHypotheses = nHypotheses;
    Obj.threshold = threshold;

end

% abstract method implementations

function t = mtpthreshold(Obj, ~, ~)
    
    % (no validation)
    
    t = Obj.threshold;
    
end

end

end