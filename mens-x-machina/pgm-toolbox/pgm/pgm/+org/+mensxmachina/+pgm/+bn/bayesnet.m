classdef(Sealed) bayesnet < org.mensxmachina.stats.cpd.cpd
%BAYESNET Bayesian network.
%   ORG.MENSXMACHINA.PGM.BN.BAYESNET is the class of Bayesian networks.
%
%   See also ORG.MENSXMACHINA.STATS.CPD.CPD.

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

properties(SetAccess = immutable)

varNames % variable names -- an 1-by-N cell array of strings
varTypes % variable types -- an 1-by-N conditional-probability-distribution-variable-type array

structure % structure -- a NxN sparse connectivity matrix
cpd % conditional probability distributions -- an 1-by-N cell array of conditional probability distributions
    
end

methods

function Obj = bayesnet(structure, cpd)
%BAYESNET Create a Bayesian network.
%   OBJ = ORG.MENSXMACHINA.PGM.BN.BAYESNET(STRUCTURE, CPD) creates a
%   Bayesian network with structure STRUCTURE and conditional probability
%   distributions CPD. STRUCTURE is an M-by-M sparse matrix representing a
%   directed acyclic graph (DAG), where M is the number of nodes
%   (variables). Nonzero elements of STRUCTURE correspond to edges in the
%   graph. CPD is a cell array of conditional probability distributions.
%   Each element of CPD contains the conditional probability distribution
%   of the corresponding node (variable) in STRUCTURE given values of its
%   parents in STRUCTURE. The parent variables come first, in the same
%   order as in STRUCTURE, and the response variable comes last.
%
%   See also ORG.MENSXMACHINA.STATS.CPD.CPD.

    import org.mensxmachina.string.strjoin;
    import org.mensxmachina.stats.cpd.cpdvartype;

    % check DAG
	assert(issparse(structure) && size(structure, 1) == size(structure, 2));
	assert(graphisdag(structure));
    
    % check cell of correct size
    validateattributes(cpd, {'cell'}, {'size', [1 size(structure, 2)]});
    
    % assert that each cell contains a CPD with a single response variable
    assert(all(cellfun(@(thisCpd) isa(thisCpd, 'org.mensxmachina.stats.cpd.cpd') && sum(thisCpd.varTypes == cpdvartype.Response) == 1, cpd)), ...
        'Each CPD must contain a single response variable.');
    
    % get variable names
    varNames = cellfun(@(thisCpd) thisCpd.varNames{find(thisCpd.varTypes == cpdvartype.Response, 1)}, cpd, 'UniformOutput', false);
    
    % assert that variable names are unique
    assert(length(unique(varNames)) == length(varNames));
    
    % assert that, for each CPD, the variables names are the parent names,
    % in the STRUCTURE order, followed by the response variable name
    
    cpdVarNamesOK = arrayfun(@(i) isequal(cpd{i}.varNames, [varNames(find(structure(:, i))') varNames{i}]), 1:length(cpd));
    
    if ~all(cpdVarNamesOK)
        
        i = find(~cpdVarNamesOK, 1);
        
        error('CPD variable names for variable %s must be %s and not %s.', ...
            varNames{i}, strjoin(cpd{i}.varNames, ', '), strjoin([varNames(find(structure(:, i))') varNames{i}], ', '));
        
    end

    % create variable types (all response)
    varTypes = repmat(cpdvartype.Response, 1, length(varNames));
    
    % set properties
    Obj.varNames = varNames;
    Obj.varTypes = varTypes;
    Obj.structure = structure;
    Obj.cpd = cpd;

%     assert(satisfiesmc(Obj));
    
end

% abstract method implementations

function D = random(Obj, DV)

    fprintf('\nSampling...\n');

    n = size(DV, 1);

    % get a topological order of the nodes
    order = graphtopoorder(Obj.structure);

    % initialize dataset variables
    vars = repmat({cell(n, 1)}, 1, length(Obj.varNames)); 

    % initialize dataset out of variables
    D = dataset(vars{:}, 'varNames', Obj.varNames);

    k = 0;

    for i = order % for each cpd in this order

        k = k + 1;

        fprintf('\nCreating column #%d, ''%s'' (%d of %d, %.2f%%)...\n', i, Obj.varNames{i}, k, length(Obj.varNames), k/length(Obj.varNames)*100);

        % get a N-by-1 dataset of random observations chosen from the conditional
        % probability distribution of the cpd for each sample
        D(:, i) = random(Obj.cpd{i}, D);

    end

end

function sref = subsref(Obj, s)
    
    if isstruct(s) && numel(s) == 1 && length(fieldnames(s)) == 2 && ...
       isfield(s, 'type') && isfield(s, 'subs') && strcmp(s.type, '()')
        
        assert(length(s.subs) == length(Obj.varNames));
        
        % get a topological order of the nodes
        order = graphtopoorder(Obj.structure);

        % initialize probabilities
        P = zeros(1, length(Obj.varNames));

        for i = order % for each cpd in this order
            
            pa_i = find(Obj.structure(:, i))';
            
            subs_cpd_i = s.subs([pa_i i]);
            
            P(i) = Obj.cpd{i}(subs_cpd_i{:});

        end
        
        sref = prod(P);
        
    else
        sref = builtin('subsref', Obj, s);
    end
    
end

function d = size(Obj, dim)
    
    import org.mensxmachina.stats.cpd.cpdvartype;
    import org.mensxmachina.array.makesize;
    
    if nargin == 1
        d = makesize(cellfun(@(icpd) size(icpd, find(icpd.varTypes == cpdvartype.Response, 1)), Obj.cpd));
    else
        parsesizeinput(Obj, dim);
        d = size(Obj.cpd{dim}, find(Obj.cpd{dim}.varTypes == cpdvartype.Response, 1));
    end
    
end

function P = permute(Obj, order)
    
    import org.mensxmachina.pgm.bn.bayesnet;
    
    parsepermuteinput(Obj, order);
    
    % permute data 
    structure = Obj.structure(order, order);
    cpd = arrayfun(@permutecpd, 1:length(Obj.cpd), 'UniformOutput', false);
    cpd = cpd(order);
    
    P = bayesnet(structure, cpd); 
    
    function iCpdPerm = permutecpd(iVar)
        
        import org.mensxmachina.array.makeorder;
        
        thisVarPaInd = find(Obj.structure(:, iVar))';
        
        thisVarPaOrder = order;
        [~, thisVarPaIndInOrder] = ismember(thisVarPaInd, thisVarPaOrder);
        thisVarPaOrder(thisVarPaIndInOrder) = 1:length(thisVarPaInd);
        thisVarPaOrder = thisVarPaOrder(sort(thisVarPaIndInOrder));
        
        thisVarFaOrder = makeorder([thisVarPaOrder (length(thisVarPaInd) + 1)]);
    
        iCpdPerm = permute(Obj.cpd{iVar}, thisVarFaOrder);
        
    end
    
end

function P = ipermute(Obj, order)
    
    import org.mensxmachina.pgm.bn.bayesnet;
    import org.mensxmachina.array.makeorder;
    
    parsepermuteinput(Obj, order);
    
    % permute data 
    structure(order, order) = Obj.structure;
    cpd(order) = Obj.cpd;
    cpd = arrayfun(@ipermutecpd, 1:length(cpd), 'UniformOutput', false);
    
    P = bayesnet(structure, cpd);
    
    function iCpdPerm = ipermutecpd(iVar)
        
        import org.mensxmachina.array.makeorder;
        
        thisVarPaInd = find(structure(:, iVar))';
        
        thisVarPaOrder = order;
        [~, thisVarPaIndInOrder] = ismember(thisVarPaInd, thisVarPaOrder);
        thisVarPaOrder(thisVarPaIndInOrder) = 1:length(thisVarPaInd);
        thisVarPaOrder = thisVarPaOrder(sort(thisVarPaIndInOrder));
        
        thisVarFaOrder = makeorder([thisVarPaOrder (length(thisVarPaInd) + 1)]);
    
        iCpdPerm = ipermute(cpd{iVar}, thisVarFaOrder);
        
    end    
    
end

% other methods

function skeleton = skeleton(Obj)
%SKELETON Bayesian network skeleton.
%   S = SKELETON(BN), when BN is a Bayesian network, returns the skeleton
%   of BN. S is an M-by-M sparse matrix, where M is the number of variables
%   of BN, representing an undirected graph. Each nonzero element in the
%   lower triangle of S denotes an edge in the graph.

skeleton = tril(Obj.structure + Obj.structure');

end 

% display methods

function disp(Obj, varargin)
%DISP Display Bayesian network.
%   DISP(BN), when BN is a Bayesian network, prints BN without displaying
%   its name.

fprintf('\n    structure\n\n');
disp(Obj.structure);

fprintf('\n    Conditional probability distributions\n\n');
cellfun(@disp, Obj.cpd);

end

function display(Obj, varargin)
%DISPLAY Display Bayesian network.
%   DISPLAY(BN), when BN is a Bayesian network, prints BN.

    fprintf('%s = \n', inputname(1));
    disp(Obj, varargin{:});

end

end

% methods(Access = private)
%     
%     function tf = satisfiesmc(Obj)
%         
%         tf = true;
%         
%         % get a topological order of the nodes
%         order = graphtopoorder(Obj.structure); 
%         
%         jTree = org.mensxmachina.pgm.bn.inference.junctiontree.jtreeinfengine(Obj);
%         
%         nLevels = cellfun(@(iRandParam) size(iRandParam.P, 1), Obj.Parameters);
%         
%         for i_order = 1:length(Obj.varNames)
%             
%             i = order(i_order);
%             
%             i
%             
%             r_i = order(1:(i_order - 1));
%             pa_i = find(Obj.structure(:, i));
%             
%             r_i_minus_pa_i = setdiff(r_i, pa_i);
%             
%             for j = r_i_minus_pa_i
%             
%                 j
%                 
%                 if ~org.mensxmachina.pgm.isindq(nLevels, i, j, pa_i, jTree)
%                     tf = false;
%                     return;
%                 end
%             
%             end
%             
%         end
%         
%     end
%     
% end

end