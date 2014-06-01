function tf = issize(a)
%ISSIZE Determine whether input is a size vector.
%   TF = ORG.MENSXMACHINA.ARRAY.ISSIZE(A) returns logical 1 (true) if A is
%   a size vector and logical 0 (false) otherwise. A size vector is a
%   numeric real row vector of >= 2 nonnegative integers.
%
%   Example:
%
%       import org.mensxmachina.array.issize;
%
%       issize([4 3])
%       issize([1])

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

tf = isnumeric(a) && isreal(a) && ndims(a) == 2 && ...
     size(a, 1) == 1 && size(a, 2) >= 2 && all(a >= 0 & round(a) == a & isfinite(a));

end