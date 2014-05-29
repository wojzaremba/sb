function vnv = datasetvarnvalues(DS, x)
%DATASETVARNVALUES Number of possible values of each dataset-array variable.
%   VNV = ORG.MENSXMACHINA.STATS.ARRAY.DATASETVARNVALUES(DS) returns the
%   number of possible values of each variable in dataset array DS. VNV is
%   a 1-by-N vector, where N is the number of variables of DS. VNV is the
%   number of levels raised to the power of the number of elements in a row
%   where the variables in DS are categorical, Inf where they are numeric
%   and NaN elsewhere.
%
%   VNV = ORG.MENSXMACHINA.STATS.ARRAY.DATASETVARNVALUES(DS, X), where X
%   specifies a variable or a set of variables in DS, returns the number of
%   possible values of the specified variables only.
%
%   Example:
% 
%       import org.mensxmachina.stats.array.datasetvarnvalues;
%
%       % create a dataset
%
%       var1 = nominal([1 2; 3 2; 1 3; 3 1; 2 3; 1 1]);
%       var2 = [1 2 3 4 5 6]';
%       var3 = {'1', '2', '3', '4', '5', '6'}';
% 
%       DS = dataset(var1, var2, var3)
%
%       % get numbers of values
%       datasetvarnvalues(DS)
%
%   See also GETLEVELS.

if nargin == 1
    
    vnv = datasetfun(@nvalues, DS);
    
else
    
    % X will be validated by datasetfun

    if isempty(x)

        % datasetfun applies the function to all variables if DataVars is empty
        vnv = zeros(1, 0);
        
        return;

    end

    vnv = datasetfun(@nvalues, DS, 'DataVars', x);
    
end

function xnv = nvalues(var)

if isa(var, 'categorical')  
    xnv = length(getlevels(var))^(numel(var)/size(var, 1));
elseif isnumeric(var)
    xnv = Inf;
else
    xnv = NaN;
end

end

end