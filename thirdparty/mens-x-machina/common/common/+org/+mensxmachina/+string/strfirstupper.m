function str = strfirstupper(str)
%STRFIRSTUPPER Convert the first letter of a string to upper case.
%   STRU = ORG.MENSXMACHINA.STRING.STRFIRSTUPPER(STR) converts the first
%   letter of string STR to upper case.
%
%   Example:
%
%       import org.mensxmachina.string.strfirstupper;
%
%       strfirstupper('foo')
%
%   See also UPPER.

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
assert(ischar(str));

str = [ upper(str(1)) str(2:end) ];
 
end
