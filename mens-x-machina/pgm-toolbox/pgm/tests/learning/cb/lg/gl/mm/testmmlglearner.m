classdef testmmlglearner < TestCase
%TESTMMLGLEARNER MMLGLEARNER test cases

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

properties
    
    bayesNet
    
    xInd % local learning target variable
    
    % symmetric CI-test based local learner
    
    citPerformer
    
    skeletonPValueLogger
    skeletonSepsetLogger
    skeletonCITLogger
    
    LocalLearner
    
    % non-symmetric CI-test based local learner
    
    nsCITPerformer
    
    nsSkeletonPValueLogger
    nsSkeletonSepsetLogger
    nsSkeletonCITLogger
    
    % DAG-based local learner
    
    nsLocalLearner
    
    dagLocalLearner

end

methods

function Obj = testmmlglearner(name)
    
    clc;

    import org.mensxmachina.stats.array.datasetvarnvalues;
    import org.mensxmachina.stats.tests.ci.chi2.gtestpvalueestimator;
    import org.mensxmachina.stats.tests.ci.chi2.heuristic.heuristicapplier;
    import org.mensxmachina.pgm.bn.learning.cb.sepsetlogger; 
    import org.mensxmachina.pgm.bn.learning.cb.cit.*;   
    import org.mensxmachina.pgm.bn.learning.cb.lg.gl.mm.cit.citcacalculator;
    import org.mensxmachina.pgm.bn.learning.cb.lg.gl.mm.*;  
    import org.mensxmachina.pgm.bn.learning.cb.dag.dagdsepdeterminer;
    import org.mensxmachina.pgm.bn.learning.cb.lg.gl.mm.dag.dagcacalculator;

    Obj = Obj@TestCase(name);

    load('alarm_bayesnet', 'BayesNet');
    load('alarm_bayesnet_sample', 'Sample'); % load sample
    
    Sample = Sample(1:500, :); % select first 500 observations
    
    Obj.bayesNet = BayesNet;
    Obj.xInd = 26;
    
    % count variables
    nVars = size(Sample, 2);
    
    % get variable number of values
    varNValues = datasetvarnvalues(Sample);
    
    % convert to double
    sample = double(Sample);
    
    % create maximal sepset cardinality
    maxSepsetCard = 10;
    
    % create CI-test p-value estimator and RC applier
    CITRCApplier = heuristicapplier(sample, varNValues);
    CITPValueEstimator = gtestpvalueestimator(sample, varNValues);
    
    % create CI-test-based d-separation determiner and CA calculator
    CITDSepDeterminer = citdsepdeterminer(CITRCApplier, CITPValueEstimator);
    CITCACalculator = citcacalculator(CITRCApplier, CITPValueEstimator);

    % create learner
    Obj.LocalLearner = mmlglearner(CITDSepDeterminer, CITCACalculator, 'maxSepsetCard', maxSepsetCard);
    
    % create various loggers
    Obj.skeletonPValueLogger = latpvaluelogger({CITDSepDeterminer, CITCACalculator}, {Obj.LocalLearner});
    Obj.skeletonCITLogger = citlogger({CITDSepDeterminer, CITCACalculator});
    Obj.skeletonSepsetLogger = sepsetlogger({Obj.LocalLearner});
    
    % create non-symmetric learner
    
    % create CI-test-based d-separation determiner and CA calculator
    CITDSepDeterminer = citdsepdeterminer(CITRCApplier, CITPValueEstimator);
    CITCACalculator = citcacalculator(CITRCApplier, CITPValueEstimator);
    
    % create learner
    Obj.nsLocalLearner = mmlglearner(CITDSepDeterminer, CITCACalculator, 'maxSepsetCard', maxSepsetCard, 'symCorrEnabled', false);
    
    % create various loggers
    Obj.nsSkeletonPValueLogger = latpvaluelogger({CITDSepDeterminer, CITCACalculator}, {Obj.nsLocalLearner});
    Obj.nsSkeletonCITLogger = citlogger({CITDSepDeterminer, CITCACalculator});
    Obj.nsSkeletonSepsetLogger = sepsetlogger({Obj.nsLocalLearner});
    
    
    % create DAG-based learner

    % create DAG-based d-separation determiner, dummy sepset cardinality bounder
    % and DAG-based CA calculator
    dagDSepDeterminer = dagdsepdeterminer(Obj.bayesNet.structure);
    dagCACalculator = dagcacalculator(Obj.bayesNet.structure);

    Obj.dagLocalLearner = mmlglearner(dagDSepDeterminer, dagCACalculator, 'maxSepsetCard', 3);
    
end

function testlearnpcwithcitdsepdeterminer(Obj)

    clc;
    
    tic;
    pc1 = Obj.LocalLearner.learnpc(Obj.xInd);
    toc
    
    p1 = Obj.skeletonPValueLogger.pValues;    
    stats1 = Obj.skeletonPValueLogger.stats;    
    sepsets1 = Obj.skeletonSepsetLogger.sepsets;
    cit1 = Obj.skeletonCITLogger.cit;
    
%     pc = pc1;
%     p = p1;    
%     stats = stats1;    
%     sepsets = sepsets1;
%     cit = cit1;
%     
%     save('mmpc_result_default', 'pc', 'p', 'stats', 'sepsets', 'cit');

    load('mmpc_result_default', 'pc', 'p', 'stats', 'sepsets', 'cit');
    
    assertEqual(pc, pc1);
    assertEqual(p, p1);
    assertEqual(stats, stats1);
    assertEqual(sepsets, sepsets1);
    
    assertEqual(cellfun(@rmtime, cit, 'UniformOutput', false), cellfun(@rmtime, cit1, 'UniformOutput', false));
    
    Obj.printlearnpcperformance(Obj.xInd, Obj.bayesNet.skeleton(), pc, p);
    
    function cit = rmtime(cit)
        
        if isstruct(cit)
            cit = rmfield(cit, 'time');
        end
        
    end

    % test non-symmetric version
    
    nsPC = Obj.nsLocalLearner.learnpc(Obj.xInd);
    
    nsP = Obj.nsSkeletonPValueLogger.pValues;

    % assert that non-symmetric version outputs more PCs
    assertTrue(all(ismember(pc, nsPC)));

    Obj.printlearnpcperformance(Obj.xInd, Obj.bayesNet.skeleton(), nsPC, nsP);
    
end

% test LEARNSKELETON

% function testlearnskeletonwithdagdsepdeterminer(Obj)
% 
%     clc;
%     
%     skeleton = Obj.dagLocalLearner.learnskeleton();
%     
%     assertEqual(skeleton, Obj.bayesNet.skeleton);
% 
% end

function testlearnskeletonwithcitdsepdeterminer(Obj)
    
    clc;
    
    import org.mensxmachina.graph.undigraphmat2vec;
    
    import org.mensxmachina.pgm.bn.learning.cb.cit.*;
    import org.mensxmachina.pgm.bn.learning.cb.lg.gl.mm.mmlglearner;
    
    tic;
    skeleton1 = Obj.LocalLearner.learnskeleton();
    toc
    
    p1 = Obj.skeletonPValueLogger.pValues;    
    stats1 = Obj.skeletonPValueLogger.stats;    
    sepsets1 = Obj.skeletonSepsetLogger.sepsets;
    cit1 = Obj.skeletonCITLogger.cit;
    
%     skeleton = skeleton1;
%     p = p1;    
%     stats = stats1;    
%     sepsets = sepsets1;
%     cit = cit1;
%     
%     save('mmpcskeleton_result_default', 'skeleton', 'p', 'stats', 'sepsets', 'cit');

    load('mmpcskeleton_result_default', 'skeleton', 'p', 'stats', 'sepsets', 'cit');
    
    assertEqual(skeleton, skeleton1);
    assertEqual(p, p1);
    assertEqual(stats, stats1);
    assertEqual(sepsets, sepsets1);
    assertEqual(cellfun(@rmtime, cit, 'UniformOutput', false), cellfun(@rmtime, cit1, 'UniformOutput', false));
    
    Obj.printlearnskeletonperformance(Obj.bayesNet.skeleton(), skeleton, p);
    
    % test non-symmetric version
    
    nsSkeleton = Obj.nsLocalLearner.learnskeleton();
    
    nsP = Obj.nsSkeletonPValueLogger.pValues;

    % assert that non-symmetric version outputs a superset of the links
    assertTrue(all(ismember(find(skeleton), find(nsSkeleton))));

    Obj.printlearnskeletonperformance(Obj.bayesNet.skeleton(), nsSkeleton, nsP);
    
    function cit = rmtime(cit)
        
        if isstruct(cit)
            cit = rmfield(cit, 'time');
        end
        
    end
    
end

end

methods(Static)

function printlearnskeletonperformance(trueSkeleton, skeleton, p)

    import org.mensxmachina.graph.undigraphmat2vec;
    import org.mensxmachina.stats.mt.quantities.*;

    % get performance object

    skeleton_true_vector = undigraphmat2vec(trueSkeleton);
    skeleton_vector = undigraphmat2vec(skeleton);

    % classification performance
    cp = classperf(skeleton_true_vector, skeleton_vector, 'Positive', 1, 'Negative', 0);

    realizedPower = cp.sensitivity
    realizedFpr = 1 - cp.specificity

    % realized FDR

    p = full(p(find(skeleton)));    
    h = logical(trueSkeleton(find(skeleton)));

    v = ntype1errors(p, h, 0.05);
    r = ndiscoveries(p, 0.05);

    realizedFdr = v/r

end  

function printlearnpcperformance(xInd, trueSkeleton, pc, p)

    import org.mensxmachina.stats.mt.quantities.*;

    % classification performance

    truelabels = full(trueSkeleton(xInd, :) | trueSkeleton(:, xInd)');
    truelabels(xInd) = [];

    classout = zeros(1, size(trueSkeleton, 1));
    classout(pc) = 1;
    classout(xInd) = [];

    cp = classperf(truelabels, classout, 'Positive', 1, 'Negative', 0);

    realizedPower = cp.sensitivity
    realizedFpr = 1 - cp.specificity

    % realized FDR
    
    p = full([p(xInd, 1:xInd) p(xInd+1:end, xInd)']); 
    p = p(pc)';
    
    h = full(trueSkeleton(xInd, :) | trueSkeleton(:, xInd)');
    h = h(pc)';

    v = ntype1errors(p, h, 0.05);
    r = ndiscoveries(p, 0.05);

end


end

end