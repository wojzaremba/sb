classdef(Sealed) tabcpd < org.mensxmachina.stats.cpd.tabular.tabpotential & org.mensxmachina.stats.cpd.cpd
%TABCPD Tabular conditional probability distribution.
%   ORG.MENSXMACHINA.STATS.CPD.TABULAR.TABCPD is the class of tabular
%   conditional probability distributions (CPDs). A tabular CPD is encoded
%   as a table.

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

properties(SetAccess = immutable)
    
    varTypes % variable types -- an 1-by-NV CPD-variable-type array

end

methods
    
% contructor

function Obj = tabcpd(varNames, varValues, varTypes, values)
%TABCPD Create tabular conditional probability distribution.
%   TABCPDOBJ = ORG.MENSXMACHINA.STATS.CPD.TABULAR.TABCPD(VARNAMES,
%   VARVALUES, VARTYPES, VALUES) creates a tabular conditional probability
%   distribution with variable names VARNAMES, variable values VARVALUES,
%   variable types VARTYPES and values VALUES. VARNAMES is an 1-by-N cell
%   array of unique variable names, where N is the number of variables.
%   VARVALUES is an 1-by-N cell array. Each element of VARVALUES is a
%   column vector containing the values of the corresponding variable.
%   VARTYPES is an 1-by-N CPD-variable-type array. Each element of VARTYPES
%   is the type of the corresponding variable (response or explanatory).
%   VALUES is a numeric real array of size
%   ORG.MENSXMACHINA.ARRAY.MAKESIZE(CELLFUN(@LENGTH, VARVALUES)). The
%   elements of VALUES are in range [0, 1]. Each element is the probability
%   of the corresponding variable-value combination. The probabilities of
%   the response-variable values sum to 1 for each combination of
%   explanatoty variable values.
%
%   See also ISVARNAME, ORG.MENSXMACHINA.STATS.CPD.CPDVARTYPE,
%   ORG.MENSXMACHINA.ARRAY.MAKESIZE.

    import org.mensxmachina.array.makesize;
    
    % call CPD constructor
    Obj = Obj@org.mensxmachina.stats.cpd.cpd();

    % call TABPOTENTIAL constructor
    Obj = Obj@org.mensxmachina.stats.cpd.tabular.tabpotential(varNames, varValues, values);
    
    % further parse input
    
    validateattributes(varTypes, {'org.mensxmachina.stats.cpd.cpdvartype'}, {'size', size(varNames)});
    
    assert(all(values(:) <= 1), 'The elements of VALUES must be <= 1.');
    assert(conditionalvaluessumto1(values, varTypes, varValues), 'The probabilities of the response-variable values must sum to 1 for each combination of explanatoty variable values.');
    
    % set var types
    Obj.varTypes = varTypes;
    
    function tf = conditionalvaluessumto1(values, varTypes, varValues)

        import org.mensxmachina.stats.cpd.cpdvartype;
        import org.mensxmachina.array.makeorder;    
        
        % detect explanatory variables
        varIsExplanatory = varTypes == cpdvartype.Explanatory;

        % detect response variables
        varIsResponse = ~varIsExplanatory;
    
        explanatoryVarValues = varValues(varIsExplanatory);
        explanatoryVarNValues = cellfun(@length, explanatoryVarValues);
        nExplanatoryVarValueCombinations = prod(explanatoryVarNValues);
        
        % bring explanatory var dimensions to the beginning
        permutedValues = permute(values, makeorder([find(varIsExplanatory) find(varIsResponse)]));
        
        % reshape into a matrix
        permutedReshapedValue = reshape(permutedValues, nExplanatoryVarValueCombinations, []);
        
        % do the check
        tf = all(abs(sum(permutedReshapedValue, 2) - 1) <= size(permutedReshapedValue, 2)*eps(class(permutedReshapedValue)));
        
    end
    
end

% abstract method implementations

function dx = random(Obj, dv)
    
    import org.mensxmachina.stats.cpd.cpdvartype;
    import org.mensxmachina.array.makesize;
    
    n = size(dv, 1);
    
    % detect explanatory variables
    varIsExplanatory = Obj.varTypes == cpdvartype.Explanatory;

    % detect response variables
    varIsResponse = ~varIsExplanatory;
        
    % count number of explanatory variable values
    explanatoryVarNValues = cellfun(@length, Obj.varValues(varIsExplanatory));

    % count number of response variable values
    responseVarNValues = cellfun(@length, Obj.varValues(varIsResponse));
        
    % count number of explanatory variable value combinations
    nExplanatoryVarValueCombinations = prod(explanatoryVarNValues);

    % count number of response variable value combinations
    nResponseVarValueCombinations = prod(responseVarNValues);

    % create P for MNRND
    
    values = Obj.values;
    
    % bring explanatory var dimensions to the beginning
    if length(Obj.varNames) > 1
        values = permute(values, [find(varIsExplanatory) find(varIsResponse)]);
    end
    
    % reshape into a matrix
    values = reshape(values, nExplanatoryVarValueCombinations, []);
    
    if sum(varIsExplanatory) == 0
    
        % create PD for each observation
        p = values;
        
    else
    
        % create explanatory var values indices
        explanatoryVarValuesInd = datasetfun(@(a) subsindex(a) + 1, dv, 'DataVars', Obj.varNames(varIsExplanatory), 'UniformOutput', false);

        % assert none of the indices is zero
        %assert(all(cellfun(@all, explanatoryVarValuesInd)));

        % create explanatory var values combination indices
        explanatoryVarValuesCombinationInd = sub2ind(makesize(explanatoryVarNValues), explanatoryVarValuesInd{:});

        % create PD for each observation
        p = values(explanatoryVarValuesCombinationInd, :);
        
    end

    % choose n random vectors from the multinomial distribution with N = 1.
    counts = mnrnd(1, p, n);
    
    % create response var values combination indices
    responseVarValueCombinationInd = counts*(1:nResponseVarValueCombinations)';
    
    % create response var values indices
    responseVarValueInd = cell(1, sum(varIsResponse));
    [responseVarValueInd{:}] = ind2sub(makesize(responseVarNValues), responseVarValueCombinationInd);
    responseVarValueInd = [responseVarValueInd{:}];
    
    % create response var values
    responseVarInd = find(varIsResponse);
    values = arrayfun(@(i) Obj.varValues{responseVarInd(i)}(responseVarValueInd(:, i), :), 1:length(responseVarInd), 'UniformOutput', false);

    % create response var dataset
    dx = dataset(values{:}, 'varNames', Obj.varNames(varIsResponse));

end

function p = permute(Obj, order)
    
    import org.mensxmachina.stats.cpd.tabular.tabcpd;
    
    varOrder = parsepermuteinput(Obj, order);
    
    % permute var values and names
    varNames = Obj.varNames(varOrder);
    varValues = Obj.varValues(varOrder);
    varTypes = Obj.varTypes(varOrder);
    values = permute(Obj.values, order);
    
    p = tabcpd(varNames, varValues, varTypes, values);
    
end

function p = ipermute(Obj, order)
    
    import org.mensxmachina.stats.cpd.tabular.tabcpd;
    
    varOrder = parsepermuteinput(Obj, order);
    
    % permute values and var values and names 
    varNames(varOrder) = Obj.varNames;
    varValues(varOrder) = Obj.varValues;
    varTypes(varOrder) = Obj.varTypes;
    values = ipermute(Obj.values, order);
    
    p = tabcpd(varNames, varValues, varTypes, values);   
    
end

% display methods 

function disp(Obj)
%DISP Display tabular conditional probability distribution.
%   DISP(P) prints conditional probability distribution P without
%   displaying its name.

    import org.mensxmachina.stats.cpd.cpdvartype;

    if isempty(Obj.varNames)
        
        str = '    Empty tabular CPD';
        
    else
        
        values = Obj.values;
        
        % detect explanatory variables
        varIsExplanatory = Obj.varTypes == cpdvartype.Explanatory;
        
        % detect response variables
        varIsResponse = ~varIsExplanatory;
        
        % bring explanatory var dimensions to the beginning
        if length(Obj.varNames) > 1
            values = permute(values, [find(varIsExplanatory) find(varIsResponse)]);
        end
        
        % count number of explanatory variable value combinations
        nExplanatoryVarValueCombinations = prod(cellfun(@length, Obj.varValues(varIsExplanatory)));
        
        % count number of response variable value combinations
        nResponseVarValueCombinations = prod(cellfun(@length, Obj.varValues(varIsResponse)));
        
        % reshape values
        values = reshape(values, nExplanatoryVarValueCombinations, []);

        obsNames = names(sum(varIsExplanatory), Obj.varNames(varIsExplanatory), Obj.varValues(varIsExplanatory), nExplanatoryVarValueCombinations, false);
        varNames = names(sum(varIsResponse), Obj.varNames(varIsResponse), Obj.varValues(varIsResponse), nResponseVarValueCombinations, true);

        tableColumns = mat2cell(values, nExplanatoryVarValueCombinations, ones(1, nResponseVarValueCombinations));

        % convert table columns to strings
        tableColumnsStr = cellfun(@(jTableColumn) num2str(jTableColumn), tableColumns, 'UniformOutput', false);

        firstColumnWidth = max(cellfun(@length, obsNames)) + 4;
        restColumnsWidth = max(cellfun(@(jVarName, jTableColumnStr) max(size(jVarName, 2), size(jTableColumnStr, 2)), varNames, tableColumnsStr)) + 4;

        % fix observation names
        obsNames = cellfun(@(obsName) [blanks(firstColumnWidth - length(obsName)) obsName], obsNames, 'UniformOutput', false);

        % fix var names
        varNames = cellfun(@(varName) [blanks(restColumnsWidth - length(varName)) varName], varNames, 'UniformOutput', false);

        % fix table column strings
        tableColumnsStr = cellfun(@(jTableColumnStr) [repmat(' ', size(jTableColumnStr, 1), restColumnsWidth - size(jTableColumnStr, 2)) jTableColumnStr], tableColumnsStr, 'UniformOutput', false);

        obsNames = cell2mat(obsNames);
        varNames = cell2mat(varNames);
        tableColumnsStr = cell2mat(tableColumnsStr);

        str = [blanks(firstColumnWidth) varNames; obsNames tableColumnsStr];
        
    end
    
    disp(str);
    fprintf('\n');
    
    function names = names(nVars, varNames, varValues, nVarValueCombinations, row)

        import org.mensxmachina.array.makesize;
        
        if nVars == 0
            names = {''};
            return;
        end
        
        % create var values strings
        varValuesString = cellfun(@(iVarValue) arrayfun(@(ijVarValue) strtrim(evalc('disp(ijVarValue);')), iVarValue, 'UniformOutput', false), varValues, 'UniformOutput', false);

        if ~row
        
            % find var values widths
            varValuesWidth = cellfun(@(iVarValueString) max(cellfun(@length, iVarValueString)), varValuesString);

            % fix var values strings
            varValuesString = cellfun(@(iVarValueString, iVarValueWidth) cellfun(@(ijVarValueString) [blanks(iVarValueWidth - length(ijVarValueString)) ijVarValueString], iVarValueString, 'UniformOutput', false), varValuesString, num2cell(varValuesWidth), 'UniformOutput', false);

        end
        
        % create var names
        varNames = repmat(varNames, nVarValueCombinations, 1);

        % create var indices
        varInd = repmat(1:nVars, nVarValueCombinations, 1);

        % create var values indices
        varValuesInd = cell(1, nVars);
        [varValuesInd{:}] = ind2sub(makesize(cellfun(@length, varValues)), (1:nVarValueCombinations)');
        varValuesInd = [varValuesInd{:}];

        % create var values
        varValuesString = arrayfun(@(ijVarInd, ijVarValueInd) varValuesString{ijVarInd}{ijVarValueInd}, varInd, varValuesInd, 'UniformOutput', false);

        % create var name - values pairs
        varNameValuePairString = cellfun(@(ijVarName, ijVarValueString) sprintf('%s = %s', ijVarName, ijVarValueString), varNames, varValuesString, 'UniformOutput', false);

        % create delimiters
        delimiter = repmat({', '}, nVarValueCombinations, nVars - 1);

        % create delimited var name - values pairs
        delimitedVarNameValuePairString = cell(nVarValueCombinations, nVars*2 - 1);
        delimitedVarNameValuePairString(:, 1:2:end) = varNameValuePairString;
        delimitedVarNameValuePairString(:, 2:2:(end-1)) = delimiter;

        % create names
        names = arrayfun(@(i) [delimitedVarNameValuePairString{i, :}], (1:nVarValueCombinations)', 'UniformOutput', false);

        if row
            names = names';
        end
        
    end

end

function display(Obj)
%DISPLAY Display tabular conditional probability distribution
%   DISPLAY(P) prints tabular conditional probability distribution P.

    fprintf('%s = \n', inputname(1));
    disp(Obj);

end

% converter methods

function Obj = potential(Obj)
%POTENTIAL Convert tabular conditional probability distribution to potential.
%   POTOBJ = POTENTIAL(TABCPDOBJ) converts tabular conditional probability
%   distribution TABCPDOBJ to a potential.

    % return as is
    
end
    
% overriden methods

function n = ndims(Obj)
    
    % call TABPOTENTIAL version
    n = ndims@org.mensxmachina.stats.cpd.tabular.tabpotential(Obj);
    
end 

end

methods(Access = protected)
    
% overriden methods   

function parsesizeinput(Obj, varargin)
    
    % call TABPOTENTIAL version
    parsesizeinput@org.mensxmachina.stats.cpd.tabular.tabpotential(Obj, varargin{:});  
    
end
 
function varOrder = parsepermuteinput(Obj, order)   
    
    % call TABPOTENTIAL version
    varOrder = parsepermuteinput@org.mensxmachina.stats.cpd.tabular.tabpotential(Obj, order);
    
end
    
end

end