classdef tabpotential < org.mensxmachina.stats.cpd.potential
%TABPOTENTIAL Tabular potential.
%   ORG.MENSXMACHINA.STATS.CPD.TABULAR.TABPOTENTIAL is the class of tabular
%   potentials. A tabular potential is encoded as a table.

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

% References:
% [1] Lauritzen, S. L., and Spiegelhalter, D. J., Local computations with
%     probabilities on graphical structures and their application to expert
%     systems, J. Roy. Statist. Soc. Ser B, 50, 157-224, 1988.

properties(SetAccess = immutable)
   
varNames % variable names -- an 1-by-NV cell array of strings
varValues % variable values -- an 1-by-NV cell array of column vectors

values % values -- an ND-dimensional numeric array
    
end

methods

% constructor

function Obj = tabpotential(varNames, varValues, values)
%TABPOTENTIAL Create tabular potential.
%   P = ORG.MENSXMACHINA.STATS.CPD.TABULAR.TABPOTENTIAL(VARNAMES,
%   VARVALUES, VARTYPES, VALUES) creates a tabular potential with variable
%   names VARNAMES, variable values VARVALUES, variable types VARTYPES and
%   values VALUES. VARNAMES is an 1-by-NV cell array of unique variable
%   names, where NV is the number of variables. VARVALUES is an 1-by-NV
%   cell array. Each element of VARVALUES is a column vector containing the
%   unique values of the corresponding variable. VARTYPES is an 1-by-N
%   CPD-variable-type array. Each element of VARTYPES is the type of the
%   corresponding variable (response or explanatory). VALUES is a numeric
%   real array of size ORG.MENSXMACHINA.ARRAY.MAKESIZE(CELLFUN(@LENGTH,
%   VARVALUES)). The elements of VALUES are all positive. Each element is
%   the value of the potential at the corresponding variable-value
%   combination.
%
%   See also ISVARNAME, ORG.MENSXMACHINA.ARRAY.MAKESIZE.

    import org.mensxmachina.array.makesize;

    % call POTENTIAL constructor
    Obj = Obj@org.mensxmachina.stats.cpd.potential();
    
    % parse input
    
    validateattributes(varNames, {'cell'}, {'row'}); 
    assert(all(cellfun(@isvarname, varNames)));
    assert(length(varNames) == length(unique(varNames)));     
    
    validateattributes(varValues, {'cell'}, {'size', size(varNames)}); 
    assert(all(cellfun(@(thisVarValues) ndims(thisVarValues) == 2 && size(thisVarValues, 2) == 1 && length(unique(thisVarValues)) == length(thisVarValues), varValues)));
    
    validateattributes(values, {'numeric'}, {'real', 'size', makesize(cellfun(@length, varValues)), 'nonnegative'}); 
    
    % set properties
    Obj.varNames = varNames;
    Obj.varValues = varValues;
    Obj.values = values;
    
end

% abstract method implementations

function sref = subsref(Obj, s)
    
    if isstruct(s) && numel(s) == 1 && length(fieldnames(s)) == 2 && ...
       isfield(s, 'type') && isfield(s, 'subs') && strcmp(s.type, '()')
        
        assert(length(s.subs) == length(Obj.varNames));
        
        sref = builtin('subsref', Obj.values, s);
        
    else
        sref = builtin('subsref', Obj, s);
    end
    
end

function varargout = size(Obj, varargin)
    
    varargout = cell(1, nargout);
    
    [varargout{:}] = size(Obj.values, varargin{:});
    
end

function p = permute(Obj, order)

    import org.mensxmachina.stats.cpd.tabular.tabpotential;
    
    varOrder = parsepermuteinput(Obj, order);
    
    % permute data    
    values = permute(Obj.values, order);    
    varValues = Obj.varValues(varOrder);
    varNames = Obj.varNames(varOrder);
    
    p = tabpotential(varNames, varValues, values);
    
end

function p = ipermute(Obj, order)

    import org.mensxmachina.stats.cpd.tabular.tabpotential;
    
    varOrder = parsepermuteinput(Obj, order);
    
    % permute data    
    values = ipermute(Obj.values, order);    
    varValues(varOrder) = Obj.varValues;
    varNames(varOrder) = Obj.varNames;
    
    p = tabpotential(varNames, varValues, values);  
    
end

% operators

function c = times(a, b)

    c = binop(a, b, @times);
    
end

function c = rdivide(a, b)

    c = binop(a, b, @rdivide);
    
    function c = rdivide(a, b)
        c = a./b;
        c(isnan(c)) = 0;
    end
    
end

function m = sum(Obj, j)
    
    import org.mensxmachina.array.*;
    import org.mensxmachina.stats.cpd.*;
    import org.mensxmachina.stats.cpd.tabular.tabpotential;

    % parse input
    parsesuminput(Obj, j);
    
    % find marginal var indices
    i = setdiff(1:length(Obj.varNames), j);
    
    if isempty(i)
        i = zeros(1, 0);
    end
    
    % get marginal var values
    xValues = Obj.varValues(i);
    
    % create marginal potential values
    
    % copy potential values
    mValues = Obj.values;
    
    % bring dimensions corresponding to non-marginal vars to the beginning
    mValues = permute(mValues, makeorder([j i]));
    
    % reshape values into matrix where the rows correspond to non-marginal
    % var values combinations
    mValues = reshape(mValues, prod(cellfun(@length, Obj.varValues(j))), []);
    
    % sum along columns
    mValues = sum(mValues, 1);
    
    % reshape values to ND-array
    
    mValues = reshape(mValues, makesize(cellfun(@length, xValues)));
    
    % get marginal var names
    xNames = Obj.varNames(i);
    
    % create marginal potential
    m = tabpotential(xNames, xValues, mValues);

end

% display methods

function disp(Obj)
%DISP Display tabular potential.
%   DISP(P) prints tabular potential P without displaying its name.

    import org.mensxmachina.array.makesize;
    
    if isempty(Obj.varNames)
        
        str = '    Empty tabular potential';
        
    else
        
        % count variable value combinations
        nVarValueCombinations = prod(cellfun(@length, Obj.varValues));

        % create var values strings
        varValuesString = cellfun(@(iVarValue) arrayfun(@(ijVarValue) strtrim(evalc('disp(ijVarValue);')), iVarValue, 'UniformOutput', false), Obj.varValues, 'UniformOutput', false);

        % find var values widths
        varValuesWidth = cellfun(@(iVarValueString) max(cellfun(@length, iVarValueString)), varValuesString);

        % fix var values strings
        varValuesString = cellfun(@(iVarValueString, iVarValueWidth) cellfun(@(ijVarValueString) [blanks(iVarValueWidth - length(ijVarValueString)) ijVarValueString], iVarValueString, 'UniformOutput', false), varValuesString, num2cell(varValuesWidth), 'UniformOutput', false);

        % create var names
        varNames = repmat(Obj.varNames, nVarValueCombinations, 1);

        % create var indices
        varInd = repmat(1:length(Obj.varNames), nVarValueCombinations, 1);

        % create var values indices
        varValuesInd = cell(1, length(Obj.varNames));
        [varValuesInd{:}] = ind2sub(makesize(cellfun(@length, Obj.varValues)), (1:nVarValueCombinations)');
        varValuesInd = [varValuesInd{:}];

        % create var values
        varValuesString = arrayfun(@(ijVarInd, ijVarValueInd) varValuesString{ijVarInd}{ijVarValueInd}, varInd, varValuesInd, 'UniformOutput', false);

        % create var name - values pairs
        varNameValuePairString = cellfun(@(ijVarName, ijVarValueString) sprintf('%s = %s', ijVarName, ijVarValueString), varNames, varValuesString, 'UniformOutput', false);

        % create delimiters
        delimiter = repmat({', '}, nVarValueCombinations, length(Obj.varNames) - 1);

        % create delimited var name - values pairs
        delimitedVarNameValuePairString = cell(nVarValueCombinations, length(Obj.varNames)*2 - 1);
        delimitedVarNameValuePairString(:, 1:2:end) = varNameValuePairString;
        delimitedVarNameValuePairString(:, 2:2:(end-1)) = delimiter;

        % create row labels
        rowLabels = [repmat(' ', nVarValueCombinations, 4) cell2mat(arrayfun(@(i) [delimitedVarNameValuePairString{i, :}], (1:nVarValueCombinations)', 'UniformOutput', false))];

        valueString = [repmat(' ', nVarValueCombinations, 4) num2str(Obj.values(:))];

        str = [rowLabels valueString];
        
    end
    
    disp(str);
    fprintf('\n');

end

function display(Obj)
%DISPLAY Display tabular potential
%   DISPLAY(P) prints tabular potential P.

    fprintf('%s = \n', inputname(1));
    disp(Obj);

end

% converters

function cpd = cpd(Obj, varargin)
    
    import org.mensxmachina.stats.cpd.tabular.tabcpd;
    
    % parse input
    varTypes = parsecpdinput(Obj, varargin{:});
    
    % construct CPD
    cpd = tabcpd(Obj.varNames, Obj.varValues, varTypes, Obj.values);
    
end

% state detectors

function tf = islikelihood(Obj)
    
    tf = all(Obj.values(:) <= 1);
    
end

% utilities
    
function p = ones(Obj, x)
    
    import org.mensxmachina.array.makesize;
    import org.mensxmachina.stats.cpd.tabular.tabpotential;

    % parse input
    parseonesinput(Obj, x);
    
    % create variable values
    varValues = Obj.varValues(x);
    
    % create potential values
    values = ones(makesize(cellfun(@length, Obj.varValues(x))));
    
    % create variable names
    varNames = Obj.varNames(x);
    
    p = tabpotential(varNames, varValues, values);
    
end
    
end

methods(Access = private)  
    
function c = binop(a, b, op)
    
    % perform binary operation

    import org.mensxmachina.array.makeorder;
    import org.mensxmachina.stats.cpd.tabular.tabpotential;

    % parse input
    assert(isa(b, 'org.mensxmachina.stats.cpd.tabular.tabpotential'));
    
    % sort A variables
    [~, order] = sort(a.varNames);
    a = permute(a, makeorder(order));
    
    % sort B variables
    [~, order] = sort(b.varNames);
    b = permute(b, makeorder(order));
    
    % find intersection
    [~, ia, ib] = intersect(a.varNames, b.varNames);
    
    % assert that common variables have the same domains
    assert(all(cellfun(@isequal, a.varValues(ia), b.varValues(ib))));
    
    % find union = variables names in C
    cVarNames = union(a.varNames, b.varNames);
    
    inACVar = ismember(cVarNames, a.varNames);
    inBCVar = ismember(cVarNames, b.varNames);
    
    % create variable values in C
    cVarValues = cell(size(cVarNames));
    cVarValues(inACVar) = a.varValues;
    cVarValues(inBCVar) = b.varValues;
    
    % count number of variables values in C
    cVarNValues = cellfun(@length, cVarValues);
    
    reshapedReplicatedAValues = reshapereplicate(a.values, inACVar);
    reshapedReplicatedBValues = reshapereplicate(b.values, inBCVar);

    % perform operation
    cValues = op(reshapedReplicatedAValues, reshapedReplicatedBValues);
    
    c = tabpotential(cVarNames, cVarValues, cValues);
    
    function replicatedReshapedValues = reshapereplicate(xValues, inXCVar)

        import org.mensxmachina.array.makesize;
        
        % insert singleton dimensions corresponding to variables not in X
        reshapedValuesSize = cVarNValues;
        reshapedValuesSize(~inXCVar) = 1;
        reshapedValuesSize = makesize(reshapedValuesSize);
        reshapedValues = reshape(xValues, reshapedValuesSize);

        % replicate values across dimensions corresponding to variables not in X
        replicatedReshapedValuesSize = cVarNValues;
        replicatedReshapedValuesSize(inXCVar) = 1;
        replicatedReshapedValuesSize = makesize(replicatedReshapedValuesSize);
        replicatedReshapedValues = repmat(reshapedValues, replicatedReshapedValuesSize);
    
    end
    
end
    
end

end