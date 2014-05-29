function str = strjoin(c, d)
%STRJOIN Join strings.
%   STR = ORG.MENSXMACHINA.STRING.STRJOIN(C, D) joins strings C with
%   delimiter D. C is a cell array of strings. D is a string. STR is a
%   string.
%
%   Example:
%
%       import org.mensxmachina.string.join;
%
%       join({'this', 'is', 'a', 'dog'})

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
validateattributes(c, {'cell'}, {'row'});
assert(all(cellfun(@(thisEl) ischar(thisEl) && ndims(thisEl) == 2 && size(thisEl, 1) == 1, c)));
validateattributes(d, {'char'}, {'row'});

nStrings = length(c);

d = repmat({d}, 1, nStrings - 1);

str = cell(1, 2*nStrings - 1);
str(1:2:end) = c;
str(2:2:end) = d;

str = [str{:}];
 
end