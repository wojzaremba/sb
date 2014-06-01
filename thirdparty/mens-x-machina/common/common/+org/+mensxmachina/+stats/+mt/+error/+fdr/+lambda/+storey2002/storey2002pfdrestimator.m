classdef(Sealed) storey2002pfdrestimator < org.mensxmachina.stats.mt.error.fdr.lambda.storey2002.storey2002fdrestimator
%STOREY2002PFDRESTIMATOR Storey (2002) pFDR estimator.
%   ORG.MENSXMACHINA.STATS.MT.ERROR.FDR.LAMBDA.STOREY2002.STOREY2002PFDRESTIMATOR
%   is the class of Storey (2002) pFDR estimators.

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

function Obj = storey2002pfdrestimator(varargin)
%STOREY2002PFDRESTIMATOR Create Storey (2002) pFDR estimator.
%   STOREY2002PFDRESTOBJ =
%   ORG.MENSXMACHINA.STATS.MT.ERROR.FDRSTOREY2002.STOREY2002PFDRESTIMATOR(M)
%   creates a Storey (2002) pFDR estimator for M hypotheses with Lambda =
%   0. M is a nonnnegative integer.
%
%   STOREY2002PFDRESTOBJ =
%   ORG.MENSXMACHINA.STATS.MT.ERROR.FDRSTOREY2002.STOREY2002PFDRESTIMATOR(M,
%   LAMBDA) uses Lambda = LAMBDA. LAMBDA is a numeric scalar in range [0,
%   1).

    % call STOREY2002FDRESTIMATOR constructor
    Obj = Obj@org.mensxmachina.stats.mt.error.fdr.lambda.storey2002.storey2002fdrestimator(varargin{:});

end

end

methods

% overriden methods

function fdr = estimateerror(Obj, p, t)
    
    % call STOREY2002FDRESTIMATOR version
    fdr = estimateerror@org.mensxmachina.stats.mt.error.fdr.lambda.storey2002.storey2002fdrestimator(Obj, p, t);

    % calculate lower bound for Pr{R(t) > 0} ([1], pp. 483-84)
    prRgt0 = 1 - (1 - t).^Obj.nHypotheses;

    fdr = fdr./prRgt0; % divide with it
    
    % set 0/0 (happens when m == 0 or t == 0) to 0
    fdr(isnan(fdr)) = 0;
    
    % limit FDR <= 1 ([1], p. 484)
    fdr = min(fdr, 1);    
    
end

end

end