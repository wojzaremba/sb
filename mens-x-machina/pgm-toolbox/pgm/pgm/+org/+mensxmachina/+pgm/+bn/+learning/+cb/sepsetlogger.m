classdef(Sealed) sepsetlogger < handle
%SEPSETLOGGER Sepset logger.
%   ORG.MENSXMACHINA.PGM.BN.LEARNING.CB.SEPSETLOGGER is the class of sepset
%   loggers. A sepset logger listens to sepsetIdentified events and logs
%   the corresponding sepsets for a set of variables.
%
%   Sepsets are stored in property sepsets. Property sepsets is an M-by-M
%   cell array, where M is the number of variables. Each value in the lower
%   triangle of property sepsets that is not [] is a numeric row vector of
%   positive integers that are the linear indices of the variables of the
%   corresponding sepset. Rest values in property sepsets are [].

% Copyright 2010-2012 Mens X Machina
% 
% This file is part of Mens X Machina Probabilistic Graphical Model
% Toolbox.
% 
% Mens X Machina Probabilistic Graphical Model Toolbox is free software:
% you can redistribute it and/or modify it under the terms of the GNU
% General Public License alished by the Free Software Foundation, either
% version 3 of the License, or (at your option) any later version.
% 
% Mens X Machina Probabilistic Graphical Model Toolbox is distributed in
% the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
% the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
% PURPOSE. See the GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License along
% with Mens X Machina Probabilistic Graphical Model Toolbox. If not, see
% <http://www.gnu.org/licenses/>.

properties(SetAccess = private)
    
sepsets % sepsets -- an M-by-M cell array
    
end

methods

% constructor

function Obj = sepsetlogger(sepsetIdentifiers)
%   OBJ = ORG.MENSXMACHINA.PGM.BN.LEARNING.CB.SEPSETLOGGER(SI) creates a
%   sepset logger that listens to sepsetIdentified events triggered by
%   sepset identifiers SI for M variables. SI is a nonempty cell row vector
%   of Objects with an nVars property with value M and a sepsetIdentified
%   event.

    % parse input
    validateattributes(sepsetIdentifiers, {'cell'}, {'row', 'nonempty'});
    assert(all(cellfun(@isscalar, sepsetIdentifiers)));
    sepsetIdentifierNVars = cellfun(@(thisSepsetIdentifier) thisSepsetIdentifier.nVars, sepsetIdentifiers);
    nVars = sepsetIdentifierNVars(1);
    assert(all(sepsetIdentifierNVars == nVars));
    
    cellfun(@addsepsetidentifierlistener, sepsetIdentifiers);
    
    % set properties
    Obj.sepsets = cell(nVars, nVars);
    
    function tf = addsepsetidentifierlistener(sepsetIdentifier)
        addlistener(sepsetIdentifier, 'sepsetIdentified', @onsepsetidentified);
        tf = true;
    end
    
    function onsepsetidentified(~, sepsetIdentifiedData)
    
        i = sepsetIdentifiedData.i;
        j = sepsetIdentifiedData.j;
        k = sepsetIdentifiedData.k;

        if j > i
            sub1 = j;
            sub2 = i;
        else
            sub1 = i;
            sub2 = j;
        end

        % set sepset
        Obj.sepsets{sub1, sub2} = k;
    
    end

end

end

end