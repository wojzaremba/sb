classdef(Sealed) sts2004fdrestimator < org.mensxmachina.stats.mt.error.fdr.lambda.storey2002.storey2002fdrestimator
%STS2004FDRESTIMATOR Storey, Taylor and Siegmund (2004) FDR estimator.
%   ORG.MENSXMACHINA.STATS.MT.ERROR.FDR.LAMBDA.STS2004.STS2004FDRESTIMATOR
%   is the class of Storey, Taylor and Siegmund (2004) FDR estimators.

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
% [1] J.D. Storey, J.E. Taylor and D. Siegmund. "Strong control,
%     conservative point estimation, and simultaneous conservative
%     consistency of false discovery rates: A unified approach", Journal of
%     the Royal Statistical Society, B (2004), 66, pp. 187-205.

methods
    
% constructor

function Obj = sts2004fdrestimator(m, lambda)
%STS2004FDRESTIMATOR Create Storey, Taylor and Siegmund (2004) FDR estimator.
%   STS2004FDRESTOBJ =
%   ORG.MENSXMACHINA.STATS.MT.ERROR.FDR.LAMBDA.STS2004.STS2004FDRESTIMATOR(M,
%   LAMBDA) creates a Storey, Taylor and Siegmund (2004) FDR estimator for
%   M hypotheses with lambda = LAMBDA. M is a nonnnegative integer. LAMBDA
%   is a numeric scalar in range (0, 1).

    % call STOREY2002FDRESTIMATOR constructor
    Obj = Obj@org.mensxmachina.stats.mt.error.fdr.lambda.storey2002.storey2002fdrestimator(m, lambda);
    
    % further parse input
    assert(lambda > 0);

end

end

methods

% overriden methods

function fdr = estimateerror(Obj, p, t)
    
    % call STOREY2002FDRESTIMATOR version
    fdr = estimateerror@org.mensxmachina.stats.mt.error.fdr.lambda.storey2002.storey2002fdrestimator(Obj, p, t);

    % set FDR(t) to 1 if t > lambda ([1], p. 192)
    fdr(t > Obj.lambda) = 1;
    
end

end

methods(Access = protected)

% overriden methods

function y = wlambda(Obj, p)

    % call STOREY2002FDRESTIMATOR version
    y = wlambda@org.mensxmachina.stats.mt.error.fdr.lambda.storey2002.storey2002fdrestimator(Obj, p);
    
    % add 1
    y = y + 1;

end

end

end