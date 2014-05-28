classdef lambdafdrestimator < org.mensxmachina.stats.mt.error.fdr.fdrestimator
%LAMBDAFDRESTIMATOR FDR estimator with parameter lambda.
%   ORG.MENSXMACHINA.STATS.MT.ERROR.FDR.LAMBDA.LAMBDAFDRESTIMATOR is the
%   abstract class of FDR estimators with parameter lambda.

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
% [2] J.D. Storey, J.E. Taylor and D. Siegmund. "Strong control,
%     conservative point estimation, and simultaneous conservative
%     consistency of false discovery rates: A unified approach", Journal of
%     the Royal Statistical Society, B (2004), 66, pp. 187-205.

properties(SetAccess = immutable)

    lambda % lambda -- a numeric scalar in range [0, 1)

end

methods
    
% constructor

function Obj = lambdafdrestimator(m, lambda)
%BY2001FDRESTIMATOR Create FDR estimator with parameter lambda.
%   LFDRESTOBJ =
%   ORG.MENSXMACHINA.STATS.MT.ERROR.FDR.LAMBDA.LAMBDAFDRESTIMATOR(M)
%   creates an FDR estimator with parameter lambda = 0 for M hypotheses. M
%   is a nonnnegative integer.
%
%   LFDRESTOBJ =
%   ORG.MENSXMACHINA.STATS.MT.ERROR.FDR.LAMBDA.LAMBDAFDRESTIMATOR(M,
%   LAMBDA) uses lambda = LAMBDA. LAMBDA is a numeric scalar in range [0,
%   1).

    % call FDRESTIMATOR constructor
    Obj = Obj@org.mensxmachina.stats.mt.error.fdr.fdrestimator(m);
    
    if nargin < 2
        lambda = 0;
    else
        validateattributes(lambda, {'numeric'}, {'scalar', 'real', 'nonnegative', '<' 1});
    end
    
    % set properties
    Obj.lambda = lambda;

end

end

methods(Access = protected)

% abstact method implementations

function y = pi0(Obj, p)
    
    if Obj.lambda == 0 % special case
        
        % [2], p. 191, but makes sense for any lambda-based estimator
        
        y = 1; % also counts zero p-values
        
        return;
        
    end

    % set PI0 = W(LAMBDA) / E[W0(LAMBDA)] ([1], p. 484)
    y = wlambda(Obj, p)/ew0lambda(Obj, p);
    
    % limit PI0 <= 1
    % [2], p. 194, but makes sense for any lambda-based estimator
    y = min(y, 1);

end

% other methods

function y = wlambda(Obj, p)

    % compute W(LAMBDA) = #{p > LAMBDA}

    % knowing that, if m > LENGTH(P) <=> m - LENGTH(P) > 0, 
    % LAMBDA < MAX(P) so for the rest m - LENGTH(P) p-values P_REST
    % ALL(P_REST > MAX(P)) => ALL(P_REST > LAMBDA)
    y = sum(p > Obj.lambda) + Obj.nHypotheses - length(p);

end

end

methods(Abstract, Access = protected)

%EW0LAMBDA Estimate EW0LAMBDA(P)
y = ew0lambda(Obj, p);

end

end