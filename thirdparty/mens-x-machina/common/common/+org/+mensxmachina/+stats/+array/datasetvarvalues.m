function vv = datasetvarvalues(DS, x)
%DATASETVARVALUES Possible values of each dataset-array variable.
%   VV = ORG.MENSXMACHINA.STATS.ARRAY.DATASETVARVALUES(DS) returns the
%   possible values of each variable in dataset array DS. VV is a 1-by-N
%   cell array, where N is the number of variables of DS. Each VV cell
%   contains the possible values of the corresponding variable and is a
%   nominal (ordinal) ND-array if the variable is nominal (ordinal) and []
%   otherwise.
%
%   Example:
% 
%       import org.mensxmachina.stats.array.datasetvarvalues;
%
%       % create a dataset
%
%       var1 = nominal([1 2; 3 2; 1 3; 3 1; 2 3; 1 1]);
%       var2 = [1 2 3 4 5 6]';
%       var3 = {'1', '2', '3', '4', '5', '6'}';
% 
%       DS = dataset(var1, var2, var3)
%
%       % get values
%       vv = datasetvarvalues(DS);
%
%       vv{:}
%
%   See also GETLEVELS.

if nargin == 1
    
    vv = datasetfun(@values, DS, 'UniformOutput', false);
    
else
    
    % X will be validated by datasetfun

    if isempty(x)

        % datasetfun applies the function to all variables if DataVars is empty
        vv = zeros(1, 0);
        
        return;

    end

    vv = datasetfun(@values, DS, 'DataVars', x, 'UniformOutput', false);
    
end

function v = values(xSample)

if isa(xSample, 'categorical')
    
    import org.mensxmachina.array.makesize;
    
    % get value size
    thisVarValueSize = size(xSample);
    thisVarValueSize(1) = [];
    thisVarValueSize = makesize(thisVarValueSize);
    
    % count number of levels
    thisVarNLevels = length(getlevels(xSample));
    
    % count number of elements
    thisVarValueNumel = prod(thisVarValueSize);
    
    % count number of values
    thisVarNValues = thisVarNLevels^thisVarValueNumel;
    
    % convert to subscripts
    thisVarValueSub = cell(1, thisVarValueNumel);
    [thisVarValueSub{:}] = ind2sub(thisVarNLevels*ones(1, thisVarValueNumel), (1:thisVarNValues)');
    thisVarValueSub = [thisVarValueSub{:}];
    
    % convert to cell
    thisVarValueSub = mat2cell(thisVarValueSub, ones(thisVarNValues, 1), thisVarValueNumel);
    
    % reshape values to their size
    thisVarValueSub = cellfun(@(thisVarThisValueSub) reshape(thisVarThisValueSub, [1 thisVarValueSize]), thisVarValueSub, 'UniformOutput', false);
    
    % convert back to matrix
    thisVarValueSub = cell2mat(thisVarValueSub);
    
    % get labels
    thisVarLabels = getlabels(xSample);
    
    % convert to categorical
    if isa(xSample, 'nominal')
        v = nominal(thisVarValueSub, thisVarLabels, 1:length(thisVarLabels));
    else
        v = ordinal(thisVarValueSub, thisVarLabels, 1:length(thisVarLabels));
    end
    
else
    v = [];
end

end

end