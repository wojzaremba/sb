classdef(Sealed) lingausscpd < org.mensxmachina.stats.cpd.cpd
%LINGAUSSCPD Linear Gaussian conditional probability distribution.
%   ORG.MENSXMACHINA.STATS.CPD.LG.LINGAUSSCPD is the class of linear
%   Gaussian conditional probability distributions. The response variables
%   of a linear Gaussian conditional probability distribution follow a
%   multivariate normal distribution with the mean of each response
%   variable being a linear function of the explanatory variable values.

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
    varNames % variable names -- an 1-by-NV cell array of strings
    
    b % response-variable regression coefficients -- an NE-by-NR numeric array
    mu % response-variable means -- an 1-by-NR numeric array
    sigma % response-variable covariance -- either an NR-by-NR or 1-by-NR numeric array

end

methods

% constructor

function Obj = lingausscpd(varNames, varTypes, b, mu, sigma)
%LINGAUSSCPD Create linear Gaussian conditional probability distribution.
%   P = ORG.MENSXMACHINA.STATS.CPD.LG.LINGAUSSCPD(VARNAMES, VARTYPES, B,
%   MU, SIGMA) creates a linear Gaussian conditional probability
%   distribution with variable names VARNAMES, variable types VARTYPES,
%   response-variable regression coefficients B, response-variable means
%   MU, and response-variable covariance SIGMA. VARNAMES is an 1-by-NV cell
%   array of unique variable names, where N is the number of variables.
%   VARTYPES is an 1-by-NV CPD-variable-type array. Each element of
%   VARTYPES specifies the type of the corresponding variable (response or
%   explanatory). B is a numeric real non-NaN NE-by-NR array, where NE and
%   NR is the number of explanatory and response variables, respectivelly.
%   Each column of B contains the regression coefficients of the
%   corresponding response variable. MU is a numeric real non-NaN 1-by-NR
%   array. Each element of MU is the mean value of the corresponding
%   variable when NE == 0 and 0 otherwise. SIGMA is a NR-by-NR symmetric
%   positive semi-definite matrix or the 1-by-NR diagonal of a diagonal
%   covariance matrix.
%
%   See also ISVARNAME, ORG.MENSXMACHINA.STATS.CPD.CPDVARTYPE, MVNRND.
    
    import org.mensxmachina.stats.cpd.cpdvartype;

    % call superclass constructor
    Obj = Obj@org.mensxmachina.stats.cpd.cpd();
    
    % parse input
    
    validateattributes(varNames, {'cell'}, {'row'}); 
    assert(all(cellfun(@isvarname, varNames)));
    assert(length(varNames) == length(unique(varNames))); 

    validateattributes(varTypes, {'org.mensxmachina.stats.cpd.cpdvartype'}, {'size', size(varNames)});
    
    nExplanatoryVars = sum(varTypes == cpdvartype.Explanatory);
    nResponseVars = sum(varTypes == cpdvartype.Response);
    
    validateattributes(b, {'numeric'}, {'real', 'size', [nExplanatoryVars nResponseVars], 'nonnan'});
    
    validateattributes(mu, {'numeric'}, {'real', 'size', [1 nResponseVars], 'nonnan'});
    assert(nExplanatoryVars == 0 || isequal(mu, zeros(1, nResponseVars)));
    
    mvnpdf(zeros(size(mu)), mu, sigma); % test SIGMA
    assert(isequal(size(sigma), [nResponseVars nResponseVars]) || isequal(size(sigma), [1 nResponseVars])); % exclude NR-by-NR-by-1 and 1-by-NR-by-1 cases
    
    % set properties
    Obj.varNames = varNames;
    Obj.varTypes = varTypes;
    Obj.b = b;
    Obj.mu = mu;
    Obj.sigma = sigma;
    
end

% abstract method implementations

function dx = random(Obj, dv, varargin)
    
    import org.mensxmachina.stats.cpd.cpdvartype;
	
    n = size(dv, 1);

    % detect explanatory variables
    varIsExplanatory = Obj.varTypes == cpdvartype.Explanatory;
    
    % detect response variables
    varIsResponse = ~varIsExplanatory;
    
    % create MU input argument of NORMRND
    mu = repmat(Obj.mu, n, 1) + double(dv, Obj.varNames(varIsExplanatory))*Obj.b;
    
    % choose random vectors from the multivariate normal distributions
    dx = mvnrnd(mu, Obj.sigma);
    
    % create response variable dataset sets
    vars = mat2cell(dx, n, ones(1, sum(varIsResponse)));
    
    % create response variable dataset
    dx = dataset(vars{:}, 'varNames', Obj.varNames(varIsResponse));
    
end

% overriden methods

function disp(Obj)
%DISP Display linear Gaussian conditional probability distribution.
%   DISP(P) prints linear Gaussian conditional probability distribution P
%   without displaying its name.

    import org.mensxmachina.stats.cpd.cpdvartype;

    % detect explanatory variables
    varIsExplanatory = Obj.varTypes == cpdvartype.Explanatory;
    
    % detect response variables
    varIsResponse = ~varIsExplanatory;
    
    % create varTypes variable name column
    conditioningVariableNamesColumn = Obj.varNames(varIsExplanatory)';

    % create response variable name column
    responseVariableNamesColumn = Obj.varNames(varIsResponse)';
    
    % create response variable name row
    responseVariableNamesRow = responseVariableNamesColumn';
    
    
    % extract b columns
    bColumn = mat2cell(Obj.b, size(Obj.b, 1), ones(1, size(Obj.b, 2)));
    
    % convert b columns to strings
    bStringColumn = cellfun(@(jBColumn) num2str(jBColumn), bColumn, 'UniformOutput', false);
    
    
    % extract MU columns
    muColumn = mat2cell(Obj.mu, size(Obj.mu, 1), ones(1, size(Obj.mu, 2)));
    
    % convert MU columns to strings
    muStringColumn = cellfun(@(jMuColumn) num2str(jMuColumn), muColumn, 'UniformOutput', false);
    
    % get SIGMA
    sigma = Obj.sigma;
    
    if isvector(sigma)
        sigma = diag(sigma); % convert to matrix
    end
    
    % extract SIGMA columns
    sigmaColumn = mat2cell(sigma, size(sigma, 1), ones(1, size(sigma, 2)));
    
    % convert SIGMA columns to strings
    sigmaStringColumn = cellfun(@(jSigmaColumn) num2str(jSigmaColumn), sigmaColumn, 'UniformOutput', false);
    
    
    firstColumnWidth = max(cellfun(@length, Obj.varNames)) + 4;
    restColumnsWidth = max(cellfun(@(jResponseVariableRow, jBColumnString, jMUColumnString, jSigmaColumnString) max([size(jResponseVariableRow, 2) size(jBColumnString, 2) size(jMUColumnString, 2) size(jSigmaColumnString, 2)]), responseVariableNamesRow, bStringColumn, muStringColumn, sigmaStringColumn)) + 4;
    
    
    % fix varTypes variable name column
    conditioningVariableNamesColumn = cellfun(@(iExplanatoryVariableColumn) [blanks(firstColumnWidth - length(iExplanatoryVariableColumn)) iExplanatoryVariableColumn], conditioningVariableNamesColumn, 'UniformOutput', false);
    
    % fix response variable name column
    responseVariableNamesColumn = cellfun(@(iResponseVariableName) [blanks(firstColumnWidth - length(iResponseVariableName)) iResponseVariableName], responseVariableNamesColumn, 'UniformOutput', false);
    
    % fix response variable name row
    responseVariableNamesRow = cellfun(@(iResponseVariableName) [blanks(restColumnsWidth - length(iResponseVariableName)) iResponseVariableName], responseVariableNamesRow, 'UniformOutput', false);
    
    
    % fix b string columns
    bStringColumn = cellfun(@(iBStringColumn) [repmat(' ', size(iBStringColumn, 1), restColumnsWidth - size(iBStringColumn, 2)) iBStringColumn], bStringColumn, 'UniformOutput', false);
    
    % fix MU string columns
    muStringColumn = cellfun(@(iMUStringColumn) [repmat(' ', size(iMUStringColumn, 1), restColumnsWidth - size(iMUStringColumn, 2)) iMUStringColumn], muStringColumn, 'UniformOutput', false);
    
    % fix SIGMA string columns
    sigmaStringColumn = cellfun(@(iSigmaStringColumn) [repmat(' ', size(iSigmaStringColumn, 1), restColumnsWidth - size(iSigmaStringColumn, 2)) iSigmaStringColumn], sigmaStringColumn, 'UniformOutput', false);

    
    fprintf('    b\n');
    disp([blanks(firstColumnWidth) cell2mat(responseVariableNamesRow); cell2mat(conditioningVariableNamesColumn) cell2mat(bStringColumn)]);
    fprintf('\n');
    
    fprintf('    mu\n');
    disp([blanks(firstColumnWidth) cell2mat(responseVariableNamesRow); blanks(firstColumnWidth) cell2mat(muStringColumn)]);
    fprintf('\n');
    
    fprintf('    sigma\n');
    disp([blanks(firstColumnWidth) cell2mat(responseVariableNamesRow); cell2mat(responseVariableNamesColumn) cell2mat(sigmaStringColumn)]);
    fprintf('\n');

end

function display(Obj)
%DISPLAY Display linear Gaussian conditional probability distribution
%   DISPLAY(P) prints linear Gaussian conditional probability distribution
%   P.

    fprintf('%s = \n', inputname(1));
    disp(Obj);

end

function sref = subsref(Obj, s)
    
    import org.mensxmachina.stats.cpd.cpdvartype;
    
    if isstruct(s) && numel(s) == 1 && length(fieldnames(s)) == 2 && ...
       isfield(s, 'type') && isfield(s, 'subs') && strcmp(s.type, '()')
        
        assert(length(s.subs) == length(Obj.varNames));
        assert(all(cellfun(@(s_i) isnumeric(s_i) && isreal(s_i) && isscalar(s_i), s.subs)));
        
        % get all values
        v = [s.subs{:}];
        
        % get response and explanatory variable values
        x = v(Obj.varTypes == cpdvartype.Response);
        y = v(Obj.varTypes == cpdvartype.Explanatory);
        
        % evaluate MVN
        sref = mvnpdf(x, Obj.mu + y*Obj.b, Obj.sigma);
        
    else
        sref = builtin('subsref', Obj, s);
    end
    
end

function varargout = size(Obj, dim)
    
    import org.mensxmachina.array.makesize;
    
    if nargin == 1
        d = makesize(Inf(1, length(Obj.varNames)));
    else
        
        parsesizeinput(Obj, dim);
        
        d = Inf;
        
    end
    
    if nargout > 1
        
        assert(nargout == ndims(Obj));
        
        varargout = num2cell(d);
        
    else
        varargout = d;
    end
    
end

function p = permute(Obj, order)
    
    import org.mensxmachina.stats.cpd.cpdvartype;
    import org.mensxmachina.stats.cpd.lg.lingausscpd;
    
    varOrder = parsepermuteinput(Obj, order);

    % detect explanatory variables
    varIsExplanatory = Obj.varTypes == cpdvartype.Explanatory;
    
    % detect response variables
    varIsResponse = ~varIsExplanatory;
    
    % permute data
    
    varNames = Obj.varNames(varOrder);
    varTypes = Obj.varTypes(varOrder);
    
    ij = zeros(1, length(Obj.varNames));
    ij(varIsResponse) = 1:sum(varIsResponse);
    ij(varIsExplanatory) = 1:sum(varIsExplanatory);
    ij = ij(varOrder);
    j = ij(varTypes == cpdvartype.Explanatory);
    i = ij(varTypes == cpdvartype.Response);
    
    b = Obj.b(j, i);
    mu = Obj.mu(i);
    
    if isvector(Obj.sigma)
        sigma = Obj.sigma(i);
    else
        sigma = Obj.sigma(i, i);
    end
    
    p = lingausscpd(varNames, varTypes, b, mu, sigma);
    
end

function p = ipermute(Obj, order)
    
    import org.mensxmachina.stats.cpd.cpdvartype;
    import org.mensxmachina.stats.cpd.lg.lingausscpd;
    
    varOrder = parsepermuteinput(Obj, order);

    % detect explanatory variables
    varIsExplanatory = Obj.varTypes == cpdvartype.Explanatory;
    
    % detect response variables
    varIsResponse = ~varIsExplanatory;
    
    % permute data
    
    varNames(varOrder) = Obj.varNames;
    varTypes(varOrder) = Obj.varTypes;
    
    ij = zeros(1, length(Obj.varNames));
    ij(varTypes == cpdvartype.Response) = 1:sum(varIsResponse);
    ij(varTypes == cpdvartype.Explanatory) = 1:sum(varIsExplanatory);
    ij = ij(varOrder);
    j = ij(varIsExplanatory);
    i = ij(varIsResponse);
    
    b(j, i) = Obj.b;
    mu(i) = Obj.mu;
    
    if isvector(Obj.sigma)
        sigma(i) = Obj.sigma;
    else
        sigma(i, i) = Obj.sigma;
    end
    
    p = lingausscpd(varNames, varTypes, b, mu, sigma);
    
end

end

end