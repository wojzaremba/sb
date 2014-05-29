classdef(Sealed) citlogger < handle
%CITLOGGER Conditional-independence-test logger.
%   ORG.MENSXMACHINA.PGM.BN.LEARNING.CB.CIT.CITLOGGER is the class of
%   conditional-independence-test (CIT) loggers. A CIT logger listens to
%   citPerformed events and logs the corresponding tests for a set of
%   variables.
%
%   CITs are stored in property cit. Property cit is an M-by-M cell array,
%   where M is the number of variables. Each value in the lower triangle of
%   property sepsets that is not [] is an 1-by-N struct, where N is the
%   number of CITs performed for the corresponding pair of variables. The
%   struct has four fields: time, condset, pValue and stat. Field time is a
%   numeric real scalar specifying the date and time (as returned by NOW)
%   the test was performed. Field condset is a numeric row vector of
%   integers in range [1, M] that are the linear indices of the
%   conditioning set variables. Field pValue and stat are numeric real
%   scalars that are the p-value and the statistic, respectivelly, of the
%   test.

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
    
cit % -- an M-by-M cell array
    
end

methods

% constructor

function Obj = citlogger(citPerformers)
%CITLOGGER Create conditional-independence-test logger.
%   OBJ = ORG.MENSXMACHINA.PGM.BN.LEARNING.CB.CIT.CITLOGGER(P) creates a
%   conditional-independence-test logger that listens to citPerformed
%   events triggered by conditional-independence-test performers P for M
%   variables. P is a nonempty cell row vector of objects with an nVars
%   property with value M and a citPerformed event.
    
    % parse input
    validateattributes(citPerformers, {'cell'}, {'row', 'nonempty'});
    assert(all(cellfun(@isscalar, citPerformers)));
    citPerformerNVars = cellfun(@(thisCITPerformer) thisCITPerformer.nVars, citPerformers);
    nVars = citPerformerNVars(1);
    assert(all(citPerformerNVars == nVars(1)));
    
    cellfun(@addcitperformerlistener, citPerformers);
    
    % initialize properties
    Obj.cit = cell(nVars, nVars);
    
    function tf = addcitperformerlistener(citPerformer)
        addlistener(citPerformer, 'citPerformed', @oncitperformed);
        tf = true;
    end
    
    function oncitperformed(~, citPerformedData)

        i = citPerformedData.i;
        j = citPerformedData.j;

        if j > i
            sub1 = j;
            sub2 = i;
        else
            sub1 = i;
            sub2 = j;
        end

        % create CI test struct
        cit = struct(...
            'time', {now}, ...
            'condset', {citPerformedData.k}, ...
            'pValue', {citPerformedData.pValue}, ...
            'stat', {citPerformedData.stat} ...
            );

        % add it to the rest
        Obj.cit{sub1, sub2} = [Obj.cit{sub1, sub2} cit];

    end
    
end

end

end