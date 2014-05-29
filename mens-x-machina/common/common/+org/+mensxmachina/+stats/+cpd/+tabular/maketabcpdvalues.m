function values = maketabcpdvalues(varTypes, values)
%MAKETABCPDVALUES Create tabular conditional probability distribution values.
%   VALUES = ORG.MENSXMACHINA.STATS.CPD.TABULAR.MAKETABCPDVALUES(VARTYPES,
%   VALUES) normalizes tabular potential values VALUES so that they can be
%   used as values in a tabular conditional probability distribution (CPD)
%   with variable types VARTYPES. VARTYPES is an 1-by-N CPD-variable-type
%   array, where N is the number of variables in the tabular CPD. Each
%   element of VARTYPES is the type of the corresponding variable (response
%   or explanatory). VALUES is a numeric real array with MAX(N, 2)
%   dimensions. The elements of VALUES are all positive.
%
%   Example:
%
%       import org.mensxmachina.stats.cpd.cpdvartype;
%       import org.mensxmachina.stats.cpd.tabular.maketabcpdvalues;
% 
%       % create tabular potential values
%       values = [0.5 0.45; 0.49 0.48]
% 
%       % create variable types
%       varTypes = [cpdvartype.Explanatory cpdvartype.Response];
% 
%       % normalize values
%       values = maketabcpdvalues(varTypes, values)
% 
%       % sum values across the response variable dimension
%       sum(values, 2)
%
%   See also ORG.MENSXMACHINA.STATS.CPD.TABULAR.TABPOTENTIAL,
%   ORG.MENSXMACHINA.STATS.CPD.TABULAR.TABCPD.

import org.mensxmachina.stats.cpd.cpdvartype;

% parse input

validateattributes(varTypes, {'org.mensxmachina.stats.cpd.cpdvartype'}, {'row'});

nVars = length(varTypes);

validateattributes(values, {'numeric'}, {'real'});
assert(ndims(values) == max(nVars, 2));

if nVars > 1

    % bring explanatory variable dimensions to the beginning
    permutedIndices = [find(varTypes == cpdvartype.Explanatory) find(varTypes == cpdvartype.Response)];
    values = permute(values, permutedIndices);
    varTypes = varTypes(permutedIndices);
    
end

valueSize = size(values);

% reshape into a matrix
nExplanatoryVarValueCombinations = prod(valueSize(varTypes == cpdvartype.Explanatory));
values = reshape(values, nExplanatoryVarValueCombinations, []);

% normalize rows
values = values./repmat(sum(values, 2), 1, size(values, 2));

% reshape back to ND-array
values = reshape(values, valueSize);

if nVars > 1

    % restore original dimension order
    values = ipermute(values, permutedIndices);
    
end

end