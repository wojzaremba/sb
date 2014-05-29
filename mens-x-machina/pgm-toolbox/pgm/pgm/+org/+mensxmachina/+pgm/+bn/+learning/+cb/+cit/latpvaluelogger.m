classdef(Sealed) latpvaluelogger < handle
%LATPVALUELOGGER Link-absence-test p-value logger.
%   ORG.MENSXMACHINA.PGM.BN.LEARNING.CB.CIT.LATPVALUELOGGER is the class of
%   link-absence-test-p-value logger. A link-absence-test-p-value logger
%   listens to citPerformed events and updates the corresponding
%   link-absence-test p-values for a set of variables. A
%   link-absence-test-p-value logger can also listen to sepsetIdentified
%   events and discard the corresponding link-absence-test p-values, if
%   they are not needed.
%
%   Link-absence-test p-values are stored in property pValues. Property
%   pValues is an M-by-M matrix, which is sparse if the logger listens to
%   sepsetIdentified events and full otherwise. In the first case, values
%   in the lower triangle of the matrix are either the current
%   link-absence-test p-values of the corresponding links or 0 if the
%   corresponding links are discarded. In the second case, all values in
%   the lower triangle are link-absence-test p-values. The rest values of
%   the matrix are 0. The statistics corresponding to the link-absence-test
%   p-values in property pValues are stored in property stats in the same
%   way.
%
%   On a citPerformed event, a link-absence-test-p-value logger sets the
%   corresponding link-absence-test p-value and statistic to the p-value
%   and statistic, respectively, of the performed test if the test is
%   complete and its p-value is greater than the corresponding stored
%   link-absence-test p-value.
%
%   On a sepsetIdentified event, a link-absence-test-p-value logger sets
%   the corresponding link-absence-test p-value to 0.

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

properties
    
pValues % p-values -- an M-by-M sparse or full matrix
stats % statistics -- an M-by-M sparse or full matrix
    
end

methods

% constructor

function Obj = latpvaluelogger(citPerformers, sepsetIdentifiers)
%   OBJ = ORG.MENSXMACHINA.PGM.BN.LEARNING.CB.CIT.LATPVALUELOGGER(P)
%   creates a link-absence-test p-value logger that listens to citPerformed
%   events triggered by conditional-independence-test performers P for M
%   variables. P is a nonempty cell row vector of Objects with an nVars
%   property with value M and a citPerformed event.
%
%   OBJ = ORG.MENSXMACHINA.PGM.BN.LEARNING.CB.CIT.LATPVALUELOGGER(P, I)
%   creates a link-absence-test p-value logger that also listens to
%   sepsetIdentified events triggered by sepset identifiers I for M
%   variables. SI is a nonempty cell row vector of Objects with an nVars
%   property with value M and a sepsetIdentified event.
    
    % parse input
    
    validateattributes(citPerformers, {'cell'}, {'row', 'nonempty'});
    assert(all(cellfun(@isscalar, citPerformers)));
    citPerformerNVars = cellfun(@(thisCITPerformer) thisCITPerformer.nVars, citPerformers);
    nVars = citPerformerNVars(1);
    assert(all(citPerformerNVars == nVars));
    
    cellfun(@addcitperformerlistener, citPerformers);
    
    if nargin > 1
    
        validateattributes(sepsetIdentifiers, {'cell'}, {'row', 'nonempty'});
        assert(all(cellfun(@isscalar, sepsetIdentifiers)));
        sepsetIdentifierNVars = cellfun(@(thisSepsetIdentifier) thisSepsetIdentifier.nVars, sepsetIdentifiers);
        assert(all(sepsetIdentifierNVars == nVars));
        
        cellfun(@addsepsetidentifierlistener, sepsetIdentifiers);
    
        % set sparse properties
        Obj.pValues = sparse(nVars, nVars);
        Obj.stats = sparse(nVars, nVars);
    
    else
    
        % set full properties
        Obj.pValues = zeros(nVars, nVars);
        Obj.stats = zeros(nVars, nVars);
        
    end
    
    function tf = addcitperformerlistener(citPerformer)
        addlistener(citPerformer, 'citPerformed', @oncitperformed);
        tf = true;
    end
    
    function tf = addsepsetidentifierlistener(sepsetIdentifier)
        addlistener(sepsetIdentifier, 'sepsetIdentified', @onsepsetidentified);
        tf = true;
    end

    function oncitperformed(~, citPerformedData)

        import org.mensxmachina.stats.tests.utils.comparepvalues;

        if isnan(citPerformedData.pValue) % incomplete test
            return;
        end

        i = citPerformedData.i;
        j = citPerformedData.j;

        p = citPerformedData.pValue;
        stat = citPerformedData.stat; 

        if j > i
            sub1 = j;
            sub2 = i;
        else
            sub1 = i;
            sub2 = j;
        end

        % for some strange reason, passing the values directly to
        % COMPAREPVALUES is extremely slow
        laPValue = Obj.pValues(sub1, sub2);
        laStat = Obj.stats(sub1, sub2);

        if comparepvalues(p, stat, laPValue, laStat) > 0

            % update link-absence-test p-value
            Obj.pValues(sub1, sub2) = p;

            % update link-absence-test p-value statistic
            Obj.stats(sub1, sub2) = stat;

        end

    end

    function onsepsetidentified(~, sepsetIdentifiedData)

        i = sepsetIdentifiedData.i;
        j = sepsetIdentifiedData.j;

        if j > i
            sub1 = j;
            sub2 = i;
        else
            sub1 = i;
            sub2 = j;
        end

        % Seriously MATLAB? Assigning 0 explicitly seems to lead to
        % copy-on-write behavior and extremely slow code!
        Obj.pValues(sub1, sub2) = zero();
        Obj.stats(sub1, sub2) = zero();

        function s = zero()
            s = 0;    
        end

    end

end

end

methods
    
end

end