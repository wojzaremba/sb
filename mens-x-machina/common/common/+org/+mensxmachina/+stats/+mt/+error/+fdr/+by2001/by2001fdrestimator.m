classdef(Sealed) by2001fdrestimator < org.mensxmachina.stats.mt.error.fdr.fdrestimator
%BY2001FDRESTIMATOR Benjamini and Yekutieli (2001) FDR estimator.
%   ORG.MENSXMACHINA.STATS.MT.ERROR.FDR.BY2001.BY2001FDRESTIMATOR is the
%   class of Benjamini and Yekutieli (2001) FDR estimators.

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
% [1] Y. Benjamini and D. Yekutieli. The control of the false discovery 
%     rate in multiple testing under dependency. Annals of p-values, pages
%     1165-1188, 2001.

methods
    
% constructor

function Obj = by2001fdrestimator(m)
%BY2001FDRESTIMATOR Create Benjamini and Yekutieli (2001) FDR estimator.
%   A = ORG.MENSXMACHINA.STATS.MT.ERROR.FDR.BY2001.BY2001FDRESTIMATOR(M)
%   creates a Benjamini and Yekutieli (2001) FDR estimator for M
%   hypotheses. M is a nonnnegative integer.

    % call FDRESTIMATOR constructor
    Obj = Obj@org.mensxmachina.stats.mt.error.fdr.fdrestimator(m);

end
    
end

methods

% overriden methods

function fdr = estimateerror(Obj, p, t)
    
    % call FDRESTIMATOR version
    fdr = estimateerror@org.mensxmachina.stats.mt.error.fdr.fdrestimator(Obj, p, t);
    
    % limit FDR <= 1
    fdr = min(fdr, 1);    
    
end

end

methods(Access = protected)

% abstract method implementations

function y = pi0(~, ~)
    y = 1;
end

function y = er0t(Obj, ~, t)

    % E[R0(t)] = m*t*sum_{1<=i<=m} 1/m
    y = Obj.nHypotheses*t*sum(1./(1:Obj.nHypotheses));

end

end

end