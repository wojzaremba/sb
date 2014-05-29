classdef testpcskeletonlearner < TestCase
%TESTPCCONSTRAINTLEARNER PCCONSTRAINTLEARNER test cases

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

methods

function Obj = testpcskeletonlearner(name)
    Obj = Obj@TestCase(name);
end

function testlearnskeletonwithcitdsepdeterminer(Obj)

    clc;

    import org.mensxmachina.stats.array.datasetvarnvalues;
    import org.mensxmachina.stats.tests.ci.chi2.gtestpvalueestimator;
    import org.mensxmachina.stats.tests.ci.chi2.heuristic.heuristicapplier;
    import org.mensxmachina.pgm.bn.learning.cb.cit.*;   
    import org.mensxmachina.pgm.bn.learning.skeleton.cb.pc.pcskeletonlearner;    
    import org.mensxmachina.graph.undigraphmat2vec;

    load('alarm_bayesnet', 'BayesNet');
    load('alarm_bayesnet_sample', 'Sample'); % load sample

    Sample = Sample(1:500, :); % select first 500 observations
    
    % get variable number of values
    varNValues = datasetvarnvalues(Sample);
    
    % convert to double
    sample = double(Sample);
    
    % create CI test p-value estimator and RC applier
    CITPValueEstimator = gtestpvalueestimator(sample, varNValues);
    CITRCApplier = heuristicapplier(sample, varNValues);
    
    % create CI-test-based d-separation determiner
    CITDSepDeterminer = citdsepdeterminer(CITRCApplier, CITPValueEstimator);
    
    % create maximal sepset cardinality
    maxSepsetCard = 10;

    skeletonLearner = pcskeletonlearner(CITDSepDeterminer, maxSepsetCard);
    
    % create skeleton p-value updater and CI-test logger
    skeletonPValueLogger = latpvaluelogger({CITDSepDeterminer});
    skeletonCITLogger = citlogger({CITDSepDeterminer});
    
    tic;
    skeleton1 = skeletonLearner.learnskeleton();
    toc
    
    p1 = skeletonPValueLogger.pValues;    
    stats1 = skeletonPValueLogger.stats;    
    sepsets1 = skeletonLearner.sepsets;
    cit1 = skeletonCITLogger.cit;
    
%     skeleton = skeleton1;
%     p = p1;    
%     stats = stats1;    
%     sepsets = sepsets1;
%     cit = cit1;
%     
%     save('pcskeleton_result_default', 'skeleton', 'p', 'stats', 'sepsets', 'cit');

    load('pcskeleton_result_default', 'skeleton', 'p', 'stats', 'sepsets', 'cit');
    
    assertEqual(skeleton, skeleton1);
    assertEqual(p, p1);
    assertEqual(stats, stats1);
    assertEqual(sepsets, sepsets1);
    assertEqual(cellfun(@rmtime, cit, 'UniformOutput', false), cellfun(@rmtime, cit1, 'UniformOutput', false));
    
    Obj.printlearnskeletonperformance(BayesNet.skeleton(), skeleton, p);
    
    function cit = rmtime(cit)
        
        if isstruct(cit)
            cit = rmfield(cit, 'time');
        end
        
    end
    
end

function testlearnskeletonwithdagdsepdeterminer(Obj)

    clc;
    
    import org.mensxmachina.pgm.bn.learning.cb.dag.dagdsepdeterminer;   
    import org.mensxmachina.pgm.bn.learning.skeleton.cb.pc.pcskeletonlearner;

    load('alarm_bayesnet', 'BayesNet');
    
    % count variables
    nVars = length(BayesNet.varNames);
    
    % create DAG-based d-separation determiner
    dagDSepDeterminer = dagdsepdeterminer(BayesNet.structure);

    skeletonLearner = pcskeletonlearner(dagDSepDeterminer);
    
    skeleton = skeletonLearner.learnskeleton();
    
    assertEqual(skeleton, BayesNet.skeleton);

end

end

methods(Static)

function printlearnskeletonperformance(skeleton_true, skeleton, p)

    import org.mensxmachina.graph.undigraphmat2vec;
    import org.mensxmachina.stats.mt.quantities.*;

    % get performance Object

    skeleton_true_vector = undigraphmat2vec(skeleton_true);
    skeleton_vector = undigraphmat2vec(skeleton);

    % classification performance
    cp = classperf(skeleton_true_vector, skeleton_vector, 'Positive', 1, 'Negative', 0);

    realizedPower = cp.sensitivity
    realizedFpr = 1 - cp.specificity

    % realized FDR

    p = full(p(find(skeleton)));    
    h = logical(skeleton_true(find(skeleton)));

    v = ntype1errors(p, h, 0.05);
    r = ndiscoveries(p, 0.05);

    realizedFdr = v/r

end        

end

end