classdef storey2002fdrestimator < org.mensxmachina.stats.mt.error.fdr.lambda.lambdafdrestimator
%STOREY2002FDRESTIMATOR Storey (2002) FDR estimator.
%   ORG.MENSXMACHINA.STATS.MT.ERROR.FDR.LAMBDA.STOREY2002.STOREY2002FDRESTIMATOR
%   is the class of Storey (2002) FDR estimators.

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
% [1] J.D. Storey. "A direct approach to false discovery rates", Journal of
%     the Royal Statistical Society, B (2002), 64(3), pp.479-498.

methods
    
% constructor

function Obj = storey2002fdrestimator(varargin)
%STOREY2002FDRESTIMATOR Create Storey (2002) FDR estimator.
%   STOREY2002FDRESTOBJ =
%   ORG.MENSXMACHINA.STATS.MT.ERROR.FDRSTOREY2002.STOREY2002FDRESTIMATOR(M)
%   creates a Storey (2002) FDR estimator for M hypotheses with lambda = 0.
%   M is a nonnnegative integer.
%
%   STOREY2002FDRESTOBJ =
%   ORG.MENSXMACHINA.STATS.MT.ERROR.FDRSTOREY2002.STOREY2002FDRESTIMATOR(M,
%   LAMBDA) uses lambda = LAMBDA. LAMBDA is a numeric scalar in range [0,
%   1).

    % call LAMBDAFDRESTIMATOR constructor
    Obj = Obj@org.mensxmachina.stats.mt.error.fdr.lambda.lambdafdrestimator(varargin{:});    

end

end

methods(Access = protected)

% abstract method implementations

function y = er0t(Obj, ~, t)

    % E[R0(t)] = m*t
    y = Obj.nHypotheses*t;
    
end

function y = ew0lambda(Obj, ~)

    % E[W0(lambda))] = (1 - lambda)*m
    y = (1 - Obj.lambda)*Obj.nHypotheses;

end

end

end