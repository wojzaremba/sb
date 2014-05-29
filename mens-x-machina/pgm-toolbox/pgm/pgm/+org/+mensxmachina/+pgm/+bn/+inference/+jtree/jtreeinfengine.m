classdef (Sealed) jtreeinfengine < org.mensxmachina.stats.cpd.inference.softinfengine
%JTREEINFENGINE Junction-tree inference engine.
%   ORG.MENSXMACHINA.PGM.BN.INFERENCE.JTREE.JTREEINFENGINE is the class of
%   junction-tree inference engines. A junction-tree inference engine
%   computes marginal distributions of single variables of a Bayesian
%   network, given evidence.
%
%   See also ORG.MENSXMACHINA.STATS.CPD.INFERENCE.INFENGINE,
%   See also ORG.MENSXMACHINA.STATS.CPD.INFERENCE.SOFTINFENGINE,
%   ORG.MENSXMACHINA.PGM.BN.BAYESNET,
%   ORG.MENSXMACHINA.STATS.CPD.POTENTIAL.

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
% [1] C. Huang and A. Darwiche. Inference in belief networks: A procedural
%     guide. International Journal of Approximate Reasoning, 15(3):225-263,
%     1996.

properties

evidence % evidence -- an 1-by-M cell array of likelihoods

end

properties(SetAccess = immutable)

nVars % number of variables -- a numeric nonnegative integer

BayesNet % bayesian network

end

properties(GetAccess = private, SetAccess = private)

faParentClusterInd % family parent-cluster indices

initialEvidence % initial evidence
prevEvidence % previous evidence

jTree % junction tree
jTreeEdgeOrder % junction tree-edge order

clusterMemberInd % cluster-member indices
clusterInitialPotentials % cluster initial potentials
clusterPotentials % cluster potentials        
clusterIsMarked % whether a cluster is marked

sepsetMemberInd % sepset-member indices
sepsetInitialPotentials % sepset initial potentials
sepsetPotentials % sepset potentials

end

methods

function Obj = jtreeinfengine(BayesNet, evidence, varWeights)
%JTREEINFENGINE Junction-tree inference engine.
%   IE = ORG.MENSXMACHINA.PGM.BN.INFERENCE.JTREE.JTREEINFENGINE(BN, W, E)
%   creates a junction-tree inference engine with Bayesian network BN and
%   evindence E, using variable weights W. BN is a Bayesian network with M
%   variables. E is an 1-by-M cell array of likelihoods. Each cell of E
%   contains the evidence for the corresponding variable. The variable name
%   and values in the likelihood must be the same as in the conditional
%   probability distribution of the corresponding variable. W is an 1-by-M
%   numeric real array with nonnegative elements. Each element of W is the
%   weight of the corresponding variable. Variable weights are used in the
%   triangulation step of building the junction tree.

    % parse input
    
    assert(isa(BayesNet, 'org.mensxmachina.pgm.bn.bayesnet'));
    validateattributes(varWeights, {'numeric'}, {'real', 'size', size(BayesNet.varNames), 'nonnegative'});
    
    validateattributes(evidence, {'cell'}, {'size', size(BayesNet.varNames)});
    assert(all(cellfun(@(thisEvidence) isa(thisEvidence, 'org.mensxmachina.stats.cpd.potential') && islikelihood(thisEvidence), evidence)), ...
        'EVIDENCE must contain likelihoods.');
    assert(all(arrayfun(@(iVar) isequal(evidence{iVar}.varNames, BayesNet.cpd{iVar}.varNames(end)), 1:length(BayesNet.varNames))), ...
        'The variable names in the likelihoods must be the same as in the conditional probability distributions.');
    assert(all(arrayfun(@(iVar) isequal(evidence{iVar}.varValues, BayesNet.cpd{iVar}.varValues(end)), 1:length(BayesNet.varNames))), ...
        'The variable values in the likelihoods must be the same as in the conditional probability distributions.');

    % set properties
    Obj.nVars = length(BayesNet.varNames);
    Obj.BayesNet = BayesNet;
    
    initialize(Obj, varWeights);
   
    Obj.evidence = evidence;

end

% property setters

function set.evidence(Obj, evidence)

%     if any(cellfun(@(a_i, iENew) any(arrayfun(@(ijE, ijENew) ijE == 0 && ijENew ~= 0, a_i, iENew)), Obj.evidence, evidence)) % global retraction
% 
%         %disp('Retracting...');

        reset(Obj); % can't check the above for general potentials, always retract

%     else
% 
%         Obj.prevEvidence = Obj.evidence;
% 
%     end            

    Obj.evidence = evidence;

    enterevidence(Obj);

    propagate(Obj);

end 

% abstract method implementations  

function m = marginal(Obj, i)

    % get FA(X) parent-cluster index
    xFAParentClusterInd = Obj.faParentClusterInd(i);
    
    % marginalize cluster potential
    m = sum(Obj.clusterPotentials{xFAParentClusterInd}, find(~ismember(Obj.clusterPotentials{xFAParentClusterInd}.varNames, Obj.BayesNet.varNames(i))));
    
    % normalize cluster potential 
    m = m./sum(m, 1);
    
    % convert to CPD
    m = cpd(m);

end

end

methods(Access = private)

function initialize(Obj, varWeights)

    import org.mensxmachina.graph.*;
    import org.mensxmachina.pgm.bn.inference.jtree.jtreeinfengine;
    import org.mensxmachina.array.makesize;

    % create junction tree

    % construct moral graph
    moralizeGraph = moralize(Obj.BayesNet.structure);

    % triangulate moral graph
    [~, Obj.clusterMemberInd clusterWeights] = triangulate(moralizeGraph, varWeights);

    % build a junction tree
    [Obj.jTree Obj.sepsetMemberInd Obj.jTreeEdgeOrder] = jtreeinfengine.cliques2jtree(Obj.clusterMemberInd, clusterWeights);

    
    % convert CPDs to potentials
    cpdPotentials = cellfun(@(thisCpd) potential(thisCpd), Obj.BayesNet.cpd, 'UniformOutput', false);
    
    
    % create initial variable potentials
    varInitialPotentials = arrayfun(@(iVar) ones(cpdPotentials{iVar}, find(strcmp(Obj.BayesNet.varNames{iVar}, cpdPotentials{iVar}.varNames), 1)), 1:length(Obj.BayesNet.varNames), 'UniformOutput', false);

    
    % Initialization ([1], p. 25)
    
    
    % Step 1.
    
    % create initial cluster potentials
    
    Obj.clusterInitialPotentials = cell(1, length(Obj.clusterMemberInd));
    
    for iCluster = 1:length(Obj.clusterMemberInd) % for each cluster
        
        Obj.clusterInitialPotentials{iCluster} = varInitialPotentials{Obj.clusterMemberInd{iCluster}(1)};
        
        for thisCliqueIMember = 2:length(Obj.clusterMemberInd{iCluster})
            
            Obj.clusterInitialPotentials{iCluster} = Obj.clusterInitialPotentials{iCluster}.*varInitialPotentials{Obj.clusterMemberInd{iCluster}(thisCliqueIMember)};
            
        end
        
    end
    
    % create initial sepset potentials
    
    Obj.sepsetInitialPotentials = cell(1, length(Obj.sepsetMemberInd));
    
    for iSepset = 1:length(Obj.sepsetMemberInd) % for each sepset
        
        Obj.sepsetInitialPotentials{iSepset} = varInitialPotentials{Obj.sepsetMemberInd{iSepset}(1)};
        
        for thisSepsetIMember = 2:length(Obj.sepsetMemberInd{iSepset})
            
            Obj.sepsetInitialPotentials{iSepset} = Obj.sepsetInitialPotentials{iSepset}.*varInitialPotentials{Obj.sepsetMemberInd{iSepset}(thisSepsetIMember)};
            
        end
        
    end
    
    
    % Step 2. (a)

    % initialize FA(X) parent-cluster indices
    Obj.faParentClusterInd = zeros(1, length(Obj.BayesNet.varNames));
    
    for iVar = 1:length(Obj.BayesNet.varNames) % for each variable
        
        % find FA_i
        thisFAInd = find(Obj.BayesNet.structure(:, iVar)');

        % find the first cluster that contains FA_i
        Obj.faParentClusterInd(iVar) = find(cellfun(@(thisClusterMemberInd) all(ismember(thisFAInd, thisClusterMemberInd)), Obj.clusterMemberInd), 1);

        Obj.clusterInitialPotentials{Obj.faParentClusterInd(iVar)} = ...
            Obj.clusterInitialPotentials{Obj.faParentClusterInd(iVar)}.*cpdPotentials{iVar};
        
    end
    

    % Step 2. (b)
    
    % create initial evidence
    Obj.initialEvidence = varInitialPotentials;

    reset(Obj);

end

function reset(Obj)

    Obj.clusterPotentials = Obj.clusterInitialPotentials;
    Obj.sepsetPotentials = Obj.sepsetInitialPotentials;
    Obj.prevEvidence = Obj.initialEvidence;

end

% % debug methods
% 
% function tf = isgloballyconsistent(Obj)
%     
%     nu = Obj.clusterPotentials{1};
% 
%     for iCluster = 2:length(Obj.clusterMemberInd) % for each cluster
%         nu = nu.*Obj.clusterPotentials{iCluster};
%     end
%     
%     de = Obj.sepsetPotentials{1};
% 
%     for iSepset = 2:length(Obj.sepsetMemberInd) % for each sepset
%         de = de.*Obj.sepsetPotentials{iSepset};
%     end
%     
%     jpd1 = nu./de;
%     
%     [~, order] = ismember(Obj.BayesNet.varNames, jpd1.varNames);
%     
%     jpd1 = permute(jpd1, order);
%     
% 
%     jpd2 = potential(Obj.BayesNet.cpd{1});
% 
%     for iVar = 2:length(Obj.BayesNet.varNames) % for each variable
%         jpd2 = jpd2.*potential(Obj.BayesNet.cpd{iVar}).*Obj.evidence{iVar};
%     end 
%     
%     [~, order] = ismember(Obj.BayesNet.varNames, jpd2.varNames);
%     
%     jpd2 = permute(jpd2, order);
%     
%     tf = all(abs(jpd1.values(:) - jpd2.values(:)) < 1e-4);
% 
% end
% 
% function tf = islocallyconsistent(Obj)
% 
%     tf = true;
% 
%     for i = 1:length(Obj.clusterMemberInd) % for each cluster X
% 
%         for j = find((Obj.jTree(i, :) | Obj.jTree(:, i)')) % for each neighboring cluster Y
% 
%             % find sepset S
%             sInd = Obj.jTreeEdgeOrder(max(i, j), min(i, j));
%             
%             m = sum(Obj.clusterPotentials{i}, setdiff(Obj.clusterPotentials{i}.varNames, Obj.sepsetPotentials{sInd}.varNames));
% 
%             if ~all(abs(m.values(:) - Obj.sepsetPotentials{sInd}.values(:)) < 1e-4)
%                 tf = false;
%                 return;
%             end
% 
%         end
% 
%     end    
% 
% end

% helper methods

function collectevidence(Obj, i)
    
    % collect evidence in X
    
    % collect evidence ([1], p. 20)

    %fprintf('\nCollecting evidence in %d...\n\n', i);

    % mark X
    Obj.clusterIsMarked(i) = true; 

    for j = find((Obj.jTree(i, :) | Obj.jTree(:, i)') & ~Obj.clusterIsMarked) % for each unmarked neighbor Y of X 
        
        % collect evidence in Y
        Obj.collectevidence(j); 
        
        % pass message from X to Y
        Obj.passmsg(j, i); 
        
    end

end

function enterevidence(Obj) 

    % Evidence entry ([1], p. 29, 6.7.2, steps 2 and 3)
    
    for iVar = 1:length(Obj.BayesNet.varNames) % for each variable

        % get FA_i parent-cluster index
        k = Obj.faParentClusterInd(iVar);

        % update FA_i parent-cluster potential
        Obj.clusterPotentials{k} = Obj.clusterPotentials{k}.*Obj.evidence{iVar}./Obj.prevEvidence{iVar};

    end

end

function propagate(Obj)
    
    % Global propagation ([1], p. 20)

    % unmark all clusters
    Obj.clusterIsMarked = false(1, length(Obj.clusterMemberInd)); 

    % collect evidence in first cluster
    Obj.collectevidence(1); 

    % unmark all clusters
    Obj.clusterIsMarked = false(1, length(Obj.clusterMemberInd)); 

    % distribute evidence from first cluster
    Obj.distributeevidence(1);
    
%     % debug
%     assert(islocallyconsistent(Obj));
%     assert(isgloballyconsistent(Obj));

end

function distributeevidence(Obj, i)
    
    % distribute evidence from X
    
    % distribute evidence ([1], p. 21)

    %fprintf('\nDistributing evidence from %d...\n\n', i);

    % mark X
    Obj.clusterIsMarked(i) = true;

    xUnmarkedNeighbors = find((Obj.jTree(i, :) | Obj.jTree(:, i)') & ~Obj.clusterIsMarked);

    for j = xUnmarkedNeighbors % for each unmarked neighbor Y of X
        
        % pass message from X to Y
        Obj.passmsg(i, j);  
        
        % distribute evidence from Y
        Obj.distributeevidence(j); 
        
    end

end

function passmsg(Obj, i, j)
    
    % message pass from X to Y ([1], p. 19, 5.3.1)

    %fprintf('Passing message from %d to %d...\n', i, j);

    % find sepset R of X and Y
    rInd = Obj.jTreeEdgeOrder(max(i, j), min(i, j));
    
    % 1. Projection

    % save sepset potential    
    oldRPotential = Obj.sepsetPotentials{rInd};

    % assign new sepset potential
    Obj.sepsetPotentials{rInd} = sum(Obj.clusterPotentials{i}, find(~ismember(Obj.clusterPotentials{i}.varNames, Obj.sepsetPotentials{rInd}.varNames)));
    
    % 2. Absorption

    % assign new cluster potentials 
    Obj.clusterPotentials{j} = Obj.clusterPotentials{j}.*Obj.sepsetPotentials{rInd}./oldRPotential;         

end     

end

methods(Static, Access = private)

function [jTree sepset order] = cliques2jtree(cliques, weights)

    import org.mensxmachina.graph.*;
    
    % [1] p. 15

    % get number of cliques
    n = length(cliques); 
    
    % get number of candidate sepsets
    m = n*(n - 1)/2;

    % initialize graph of cliques, candidate sepsets, mass and cost
    G = spalloc(n, n, m);
    sepset = cell(1, m);
    mass = zeros(m, 1);
    cost = zeros(m, 1);

    k = 0;

    for j = 1:n    
        for i = (j + 1):n  

            % for each pair (i, j) of cliques

            k = k + 1;

            G(i, j) = 1;

            % create candidate sepset S_ij
            sepset{k} = intersect(cliques{i}, cliques{j});

            % calculate its mass
            mass(k) = length(sepset{k});

            % calculate its cost
            cost(k) = weights(i) + weights(j);

        end
    end

    edgeWeight = [-mass cost];

    % find minimal spanning jTree for the graph of cliques
    jTree = prim(G, edgeWeight, 1);

    [row col] = find(jTree);
    ind = (col - 1).*(n - col/2) + row - col;
    sepset = sepset(ind);
    order = sparse(row, col, 1:(n - 1), n, n);

end

end

end