function x = makeorder(x)
%MAKEORDER Make order vector.
%   X = ORG.MENSXMACHINA.ARRAY.MAKEORDER(X) corrects 1-by-M (M >= 0)
%   numeric array X of unique integers in [1 M] to make an order vector for
%   use with PERMUTE. An order vector has length >= 2.
%
%   Example:
%
%       import org.mensxmachina.array.makeorder;
%
%       makeorder(zeros(1, 0))
%       makeorder([1])
%       makeorder([3 1 2])
%       
%   See also PERMUTE, ORG.MENSXMACHINA.ARRAY.ISORDER.

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

% no validation

if length(x) < 2
    x = [1 2];
end

end