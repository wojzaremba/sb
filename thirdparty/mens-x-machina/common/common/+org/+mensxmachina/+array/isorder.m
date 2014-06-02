function tf = isorder(a)
%ISORDER Determine whether input is an order vector.
%   TF = ORG.MENSXMACHINA.ARRAY.ISORDER(A) returns logical 1 (true) if A is
%   an order vector for use with PERMUTE and logical 0 (false) otherwise.
%   An order vector is a numeric row vector of M >= 2 unique integers in [1
%   M].
%
%   Example:
%
%       import org.mensxmachina.array.isorder;
%
%       isorder([1 3 2])
%       isorder([1])

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

tf = isnumeric(a) && isreal(a) && ... % class
     ndims(a) == 2 && size(a, 1) == 1 && size(a, 2) >= 2 && ... % size
     all(a >= 1 & a <= length(a) & round(a) == a) && ... % elements
     length(unique(a)) == length(a); % element uniqueness

end