classdef(Sealed) bdeucpdlearner < org.mensxmachina.pgm.bn.learning.cpd.cpdlearner
%BDEUCPDLEARNER BDeu-conditional-probability-distribution learner.
%   ORG.MENSXMACHINA.PGM.BN.LEARNING.CPD.BDEU.BDEUCPDLEARNER is the class
%   of BDeu-conditional-probability-distribution learners.

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

% References:
% [1] Heckerman, D. E., Geiger, D., & Chickering, D. M. (1995). Learning
%     Bayesian networks: The combination of knowledge and statistical 
%     sample. Machine Learning, 20, 197-243.

properties(SetAccess = immutable)
     
varNames % variable names -- an 1-by-M cell array of strings   
    
structure % structure -- an M-by-M sparse matrix representing a DAG

end

properties(GetAccess = private, SetAccess = immutable)

varValues % variable values -- an 1-by-N cell array of column vectors
varNValues % variable numbers of values -- an 1-by-N numeric vector of positive integers

sample % sample -- an M-by-N numeric matrix of positive integers

equivalentSampleSize % equivalent sample size -- a numeric nonnegative integer

end

methods

function Obj = bdeucpdlearner(varNames, varValues, structure, sample, equivalentSampleSize)
%BDEUCPDLEARNER Create BDeu-conditional-probability-distribution learner.
%   OBJ =
%   ORG.MENSXMACHINA.PGM.BN.LEARNING.CPD.BDEU.BDEUCPDLEARNER(VARNAMES,
%   VARVALUES, G, D) creates a BDeu-conditional-probability-distribution
%   learner with variable names VARNAMES, variable values VARVALUES,
%   structure G, sample D, and equivalent sample size 10. VARNAMES is an
%   1-by-N cell array of unique variable names, where N is the number of
%   variables. VARVALUES is an 1-by-N cell array. Each element of VARVALUES
%   is a column vector containing the values of the corresponding variable.
%   G is an M-by-M sparse matrix. Each nonzero element in G denotes an edge
%   in the graph. SAMPLE is an M-by-N numeric matrix of positive integers,
%   where M is the number of observations. Each element of SAMPLE is the
%   linear index of the value of the corresponding variable for the
%   corresponding observation.
%
%   OBJ =
%   ORG.MENSXMACHINA.PGM.BN.LEARNING.CPD.BDEU.BDEUCPDLEARNER(VARNAMES,
%   VARVALUES, G, D, ESS) uses equivalent sample size ESS. ESS is a is a
%   numeric nonnegative integer.

    % parse input
    
    validateattributes(varNames, {'cell'}, {'row'}); 
    assert(all(cellfun(@isvarname, varNames)));
    assert(length(varNames) == length(unique(varNames)));   
    
    validateattributes(varValues, {'cell'}, {'size', size(varNames)}); 
    assert(all(cellfun(@(thisVarValues) ndims(thisVarValues) == 2 && size(thisVarValues, 2) == 1 && length(unique(thisVarValues)) == length(thisVarValues), varValues)));

	assert(issparse(structure));
	assert(size(structure, 1) == length(varNames) && size(structure, 2) == length(varNames));
	assert(graphisdag(structure));
    
    validateattributes(sample, {'numeric'}, {'2d', 'ncols', length(varNames), 'positive', 'integer'});
    
    if nargin < 5
        equivalentSampleSize = 10;
    else
        validateattributes(equivalentSampleSize, {'numeric'}, {'scalar', 'nonnegative', 'integer'});
    end
    
    % count the values of each variable
    varNValues = cellfun(@length, varValues);
    
    % set properties
    Obj.varNames = varNames;
    Obj.varValues = varValues;
    Obj.varNValues = varNValues;
    Obj.structure = structure;
    Obj.sample = sample;
    Obj.equivalentSampleSize = equivalentSampleSize;

end

% abstract method implementations

function cpd = learncpd(Obj)
    
    import org.mensxmachina.stats.cpd.cpdvartype;    
    import org.mensxmachina.array.makesize;
    import org.mensxmachina.stats.cpd.tabular.tabcpd;
    
    nVars = length(Obj.varNames);
    
    % initialize CPDs
    cpd = cell(1, nVars);
    
    for i = 1:nVars
        
        % find PA(X)
        j = find(Obj.structure(:, i)');
        
        % start copy-paste from BDEULOCALSCORER

        % select PA(X) number of values
        xPANValues = Obj.varNValues(j);

        % select X number of values
        xNValues = Obj.varNValues(i);

        % select FA(X) sample
        xFASample = Obj.sample(:, [j i]);

        sampleSize = size(xFASample, 1);

        % compute counts
        N = accumarray(xFASample, ones(1, sampleSize), makesize([xPANValues xNValues]));

        nXPAValues = prod(xPANValues);

        N_ijk = reshape(N, nXPAValues, xNValues);
        N_ij = sum(N_ijk, 2);
        N_prime_ijk = Obj.equivalentSampleSize*ones(nXPAValues, xNValues)./(nXPAValues*xNValues);
        N_prime_ij = sum(N_prime_ijk, 2);
        
        % end copy-paste from BDEULOCALSCORER
        
        % create variable values
        xCpdVarValues = [Obj.varValues(j) Obj.varValues(i)];
        
        % create variable types
        xCpdVarTypes = [repmat(cpdvartype.Explanatory, 1, length(j)) cpdvartype.Response];
        
        % create values
        xCpdValues = (N_ijk + N_prime_ijk) ./ (repmat(N_ij, 1, Obj.varNValues(i)) + repmat(N_prime_ij, 1, Obj.varNValues(i)));
        xCpdValues = reshape(xCpdValues, makesize([xPANValues xNValues]));
        
        % get variable names
        xCpdVarNames = [Obj.varNames(j) Obj.varNames(i)];
        
        % create tabular CPD
        cpd{i} = tabcpd(xCpdVarNames, xCpdVarValues, xCpdVarTypes, xCpdValues);
        
    end
    
end

end

end