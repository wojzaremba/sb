function latextablewrite(filePath, ds, varargin)
%LATEXTABLEWRITE Write LaTeX table.
%	ORG.MENSXMACHINA.STATS.ARRAY.IO.LATEX.LATEXTABLEWRITE(FILEPATH, DS)
%	writes in file FILEPATH LaTeX code that creates the N'-by-M' table
%	represented by N-by-M dataset array DS whose variables are numeric
%	columns, categorical columns, or cell columns of strings. N' = N + 1
%	and the first row of the table contains the variable names in DS. When
%	there are no observation names in DS, M' = M, otherwise M' = M + 1 and
%	the first column of the table contains the observation names in DS.
%
%   ORG.MENSXMACHINA.STATS.ARRAY.IO.LATEX.LATEXTABLEWRITE(FILEPATH, DS,
%   'Param1', VAL1, 'Param2', VAL2, ...) specifies additional parameter
%   name/value pairs chosen from the following:
%
%       'environment'   The LaTeX environment to be used. ENVIRONMENT is
%                       'tabular', 'supertabular*', 'supertabular',
%                       'supertabular*', 'mpsupertabular or
%                       'mpsupertabular*'. Default is 'tabular'.
%
%       'format'        The format of the NUM2STR function used to convert
%                       numbers in matrix or dataset DS to strings. Default
%                       is '%11.4g'.
%
%       'obsLabels'     Observation labels in the first column of the
%                       table. OBSLABELS is either {} or an N-by-1 cell
%                       array of strings. If OBSLABELS is {} then M' =
%                       M. Default is the observations names in DS.
%
%       'spec'          The LaTeX table specification. Default is a series
%                       of M' r's in a row specifying M' left-justified
%                       columns without any vertical lines between them.
% 
%       'varLabels'     Variable labels in the first row of the table.
%                       VARLABELS is either {} or an 1-by-M cell array of
%                       strings. If VARLABELS is {}, N' = N. Default is the
%                       variable names in DS.
%
%   See also NUM2STR.

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

% parse input arguments with inputParser
ip = inputParser;

ip.addRequired('filePath', @ischar);
ip.addRequired('ds', @(a) isa(a, 'dataset'));
ip.addParamValue('environment', 'tabular', @(env) ischar(env) && ismember(env, {'tabular', 'supertabular*', 'supertabular', 'supertabular*', 'mpsupertabular', 'mpsupertabular*'}));
ip.addParamValue('spec', [], @ischar);
ip.addParamValue('format', '%11.4g', @ischar);
ip.addParamValue('obsLabels', {}, @(obsLabels) isequal(obsLabels, {}) || (iscellstr(obsLabels) && isequal(size(obsLabels), [size(ds, 1) 1])));
ip.addParamValue('varLabels', {}, @(varLabels) isequal(varLabels, {}) || (iscellstr(varLabels) && isequal(size(varLabels), [1 size(ds, 2)])));

ip.parse(filePath, ds, varargin{:});

Param = ip.Results;

[nObs nVars] = size(ds);

multipage = ismember(Param.environment, {'supertabular', 'supertabular*', 'mpsupertabular', 'mpsupertabular*'});

if isequal(Param.varLabels, {})
    Param.varLabels = ds.Properties.VarNames;   
end

if isequal(Param.obsLabels, {})
    Param.obsLabels = ds.Properties.ObsNames;   
end

if isequal(Param.spec, [])
    
    nCols = nVars;
    
    if ~isempty(Param.obsLabels)
        nCols = nCols + 1;
    end
    
    Param.spec = [' ' repmat('r ', 1, nCols)];
    
else
    Param.spec = [' ' Param.spec ' '];
end

% open the file with write permission
fid = fopen(sprintf('%s.tex', filePath), 'w');

if multipage
    
    % \tablefirsthead
    fprintf(fid, '\\tablefirsthead{\n');
    header(fid, Param.varLabels, Param.obsLabels)
    fprintf(fid, '}\n');
    
    % \tablehead
    fprintf(fid, '\\tablehead{\n');
    fprintf(fid, '\t\\multicolumn{%d}{l}{\\small\\sl continued from previous page}\\\\\n', size(a, 2));
    fprintf(fid, '\t\\hline\n');
    header(fid, Param.varLabels, Param.obsLabels)
    fprintf(fid, '}\n');
    
    % \tabletail
    fprintf(fid, '\\tabletail{\n');
    fprintf(fid, '\t\\hline\n');
    fprintf(fid, '\t\\multicolumn{%d}{r}{\\small\\sl continued on next page}\\\\\n', size(a, 2));
    fprintf(fid, '}\n');
    
    % \tablelasttail
    fprintf(fid, '\\tablelasttail{}');
    
end

fprintf(fid, '\\begin{%s}{%s}\n', Param.environment, Param.spec);

dsVarIsNumericColumn = datasetfun(@(thisDsVar) isnumeric(thisDsVar) && ndims(thisDsVar) == 2 && size(thisDsVar, 2) == 1, ds);
dsVarIsCategoricalColumn = datasetfun(@(thisDsVar) isa(thisDsVar, 'categorical') && ndims(thisDsVar) == 2 && size(thisDsVar, 2) == 1, ds);
dsVarIsCellStrColumn = datasetfun(@(thisDsVar) iscellstr(thisDsVar) && ndims(thisDsVar) == 2 && size(thisDsVar, 2) == 1, ds);

assert(all(dsVarIsNumericColumn | dsVarIsCategoricalColumn | dsVarIsCellStrColumn));

for j = find(dsVarIsCategoricalColumn) % for each categorical variable

    jVarName = a.Properties.VarNames{j};
    jVar = a.(jVarName);

    a.(jVarName) = cellstr(jVar); % convert to string

end

if ~multipage
    header(fid, Param.varLabels, Param.obsLabels)
end

for iObs = 1:nObs % for each observation

    fprintf(fid, '\t');

    if ~isempty(Param.obsLabels)
        fprintf(fid, ' %s & ', Param.obsLabels{iObs}); % print observation name
    end

    for iVar = 1:nVars % for each variable

        if dsVarIsNumericColumn(iVar)
            fprintf(fid, num2str(double(ds(iObs, iVar)), Param.format)); % print number
        else
            fprintf(fid, '%s', ds{iObs, iVar}); % print string
        end

        if iVar < nVars
            fprintf(fid, ' & ');
        end

    end

    fprintf(fid, ' \\\\\n');

end

fprintf(fid, '\\end{%s}', Param.environment);

end

% header function

function header(fid, varLabels, obsLabels)
    
    if isempty(varLabels)
        return;
    end

    fprintf(fid, '\t');
        
    if ~isempty(obsLabels)
        fprintf(fid, '  & ');
    end
    
    nVars = length(varLabels);
    
    for iVar = 1:nVars % for each variable
    
        fprintf(fid, '%s', varLabels{iVar}); % print variable name
            
        if iVar < nVars
            fprintf(fid, ' & ');
        end
        
    end

    fprintf(fid, ' \\\\\n\t\\hline\n');

end