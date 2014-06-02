classdef mtpapplier < handle
%MTPAPPLIER Multiple-testing-procedure applier.
%   ORG.MENSXMACHINA.STATS.MT.MTP.MTPAPPLIER is the abstract class of
%   multiple-testing-procedure (MTP) appliers. An MTP applier applies an
%   MTP to p-values corresponding to some subset of a set of hypotheses.

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
    
nHypotheses % number of hypotheses -- a nonnegative integer
    
end

methods(Abstract)
    
%MTPTHRESHOLD Multiple testing procedure threshold.
%   T = MTPTHRESHOLD(MTPAPPLIEROBJ, P), where MTPAPPLIEROBJ is a
%   multiple-testing-procedure (MTP) applier for M hypotheses and P is a
%   set of p-values corresponding to a subset of the hypotheses, returns
%   the threshold T selected by the MTP when applied to P. Rest p-values
%   are assumed to be in range (MAX(P), 1]. P is an N-by-1 (N <= M) numeric
%   array with values in range [0, 1]. T is a numeric real scalar.
t = mtpthreshold(Obj, p)

end

methods(Access = protected)
    
function parsethresholdinput(Obj, p)
%PARSETHRESHOLDINPUT Parse ORG.MENSXMACHINA.STATS.MT.MTP.MTPAPPLIER/THRESHOLD input.
%   PARSETHRESHOLDINPUT(A, ...), when A is a multiple-testing-procedure
%   applier array, throws an error if its input is not valid input for
%   ORG.MENSXMACHINA.STATS.MT.MTP.MTPAPPLIER/THRESHOLD.
%
%   See also ORG.MENSXMACHINA.STATS.MT.MTP.MTPAPPLIER/THRESHOLD.
   
assert(isscalar(Obj));
validateattributes(p, {'numeric'}, {'column', 'real', 'nonnegative', '<=' 1});
assert(length(p) <= Obj.nHypotheses);

end
    
end

end