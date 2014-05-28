function v = ntype1errors(p, h, t)
%NTYPE1ERRORS Number of type I errors.
%   V = ORG.MENSXMACHINA.STATS.MT.QUANTITIES.NTYPE1ERRORS(P, H, T)
%   calculates the number V of type I errors when rejecting hypotheses with
%   corresponding p-value <= each the p-value thresholds T. P is an M-by-1
%   numeric array with values in range [0, 1]. H is an M-by-1 logical array
%   which is false where the null hypotheses are true and true where the
%   alternative hypotheses are true. T and V are N-by-1 numeric real
%   arrays.
%
%   Example:
%
%       import org.mensxmachina.stats.mt.quantities.ntype1errors;
%
%       p = [0.001 0.01 0.05 0.1 0.5 1]';
%       h = logical([1 1 0 0 0 0])';
%       t = [0.03 0.7]';
%
%       ntype1errors(p, h, t)
%
%   See also ORG.MENSXMACHINA.STATS.MT.QUANTITIES.NTYPE2ERRORS,
%   ORG.MENSXMACHINA.STATS.MT.QUANTITIES.NDISCOVERIES.

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

% parse input

validateattributes(p, {'numeric'}, {'real', 'column', 'nonnegative', '<=' 1});
validateattributes(h, {'logical'}, {'real', 'size', size(p)});
validateattributes(t, {'numeric'}, {'real', 'column'});
   
m0 = sum(~h);

% sort thresholds
[t_sorted t_order] = sort(t);
    
t_sorted_reversed = -t_sorted(end:-1:1);
t_sorted_reversed(end + 1) = Inf;


% calculate V(t)

v = zeros(size(t));

if m0 > 0

    % -t_(k) <= -t < -t_(k-1) <=> t_(k-1) < t <= t_(k)
    counts = histc(-p(~h), t_sorted_reversed);

    v(t_order) = cumsum(counts(end-1:-1:1));

end

end