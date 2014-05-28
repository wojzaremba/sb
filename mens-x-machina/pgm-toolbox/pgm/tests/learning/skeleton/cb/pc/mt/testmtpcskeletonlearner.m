classdef testmtpcskeletonlearner < TestCase
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

function Obj = testmtpcskeletonlearner(name)

    Obj = Obj@TestCase(name);

end

function testlearnskeleton(Obj)

    clc;

    import org.mensxmachina.stats.array.datasetvarnvalues;
    import org.mensxmachina.stats.tests.ci.chi2.gtestpvalueestimator;
    import org.mensxmachina.stats.tests.ci.chi2.heuristic.heuristicapplier;
    import org.mensxmachina.stats.mt.mtp.fixedthresholdapplier;
    import org.mensxmachina.pgm.bn.learning.cb.cit.citlogger;   
    import org.mensxmachina.pgm.bn.learning.skeleton.cb.pc.mt.mtpcskeletonlearner;
    
    import org.mensxmachina.graph.*;

    load('alarm_bayesnet', 'BayesNet');
    load('alarm_bayesnet_sample', 'Sample');

    Sample = Sample(1:500, :); % select first 500 observations
    
    % count variables
    nVars = size(Sample, 2);
    
    % get variable number of values
    varNValues = datasetvarnvalues(Sample);
    
    % convert to double
    sample = double(Sample);
    
    % create CI test p-value estimator and RC applier
    CITPValueEstimator = gtestpvalueestimator(sample, varNValues);
    CITRCApplier = heuristicapplier(sample, varNValues);
    
    % create fixed-threshold-MTP applier
    MtpApplier = fixedthresholdapplier(nVars*(nVars - 1)/2, 0.05);
    
    % create maximal sepset cardinality
    maxSepsetCard = 10;

    skeletonLearner = mtpcskeletonlearner(CITRCApplier, CITPValueEstimator, MtpApplier, maxSepsetCard);
    
    % create CI-test logger
    skeletonCITLogger = citlogger({skeletonLearner});
    
    tic;
    skeleton1 = skeletonLearner.learnskeleton();
    toc
    
    p1 = skeletonLearner.pValues;    
    stats1 = skeletonLearner.stats;
    cit1 = skeletonCITLogger.cit;

    load('../pcskeleton_result_default', 'skeleton', 'p', 'stats', 'sepsets', 'cit');
    
    assertEqual(skeleton, skeleton1);
    assertEqual(full(p(find(skeleton))), p1(find(skeleton)));
    assertEqual(full(stats(find(skeleton))), stats1(find(skeleton)));    
    assertEqual(cellfun(@rmtime, cit, 'UniformOutput', false), cellfun(@rmtime, cit1, 'UniformOutput', false));
    
    Obj.printlearnskeletonperformance(BayesNet.skeleton(), skeleton, p);
    
    function cit = rmtime(cit)
        
        if isstruct(cit)
            cit = rmfield(cit, 'time');
        end
        
    end
    
end

function testlearnfdrskeleton(Obj)

    clc;

    import org.mensxmachina.stats.array.datasetvarnvalues;
    import org.mensxmachina.stats.tests.ci.chi2.gtestpvalueestimator;
    import org.mensxmachina.stats.tests.ci.chi2.heuristic.heuristicapplier;
    import org.mensxmachina.stats.mt.error.fdr.by2001.by2001fdrestimator;
    import org.mensxmachina.stats.mt.mtp.error.errormtpapplier;
    import org.mensxmachina.pgm.bn.learning.cb.cit.citlogger;   
    import org.mensxmachina.pgm.bn.learning.skeleton.cb.pc.mt.mtpcskeletonlearner;
    
    import org.mensxmachina.graph.*;

    load('alarm_bayesnet', 'BayesNet');
    load('alarm_bayesnet_sample', 'Sample');

    Sample = Sample(1:500, :); % select first 500 observations
    
    % count variables
    nVars = size(Sample, 2);
    
    % get variable number of values
    varNValues = datasetvarnvalues(Sample);
    
    % convert to double
    sample = double(Sample);
    
    % create CI test p-value estimator and RC applier
    CITPValueEstimator = gtestpvalueestimator(sample, varNValues);
    CITRCApplier = heuristicapplier(sample, varNValues);
    
    % create FDR estimator
    FdrEstimator = by2001fdrestimator(nVars*(nVars - 1)/2);
    
    % create applier
    MtpApplier = errormtpapplier(FdrEstimator, 0.05);
    
    % create maximal sepset cardinality
    maxSepsetCard = 10;

    skeletonLearner = mtpcskeletonlearner(CITRCApplier, CITPValueEstimator, MtpApplier, maxSepsetCard);
    
    tic;
    skeleton = skeletonLearner.learnskeleton();
    toc
    
    p = skeletonLearner.pValues;
    
    Obj.printlearnskeletonperformance(BayesNet.skeleton(), skeleton, p);
    
end

function testlearnskeletonwithdagcitpvalueestimator(Obj)

    clc;
    
    import org.mensxmachina.pgm.bn.learning.cb.cit.dag.dagcitpvalueestimator;
    import org.mensxmachina.stats.tests.ci.dummycitrcapplier;
    import org.mensxmachina.stats.mt.mtp.fixedthresholdapplier;
    import org.mensxmachina.pgm.bn.learning.skeleton.cb.pc.mt.mtpcskeletonlearner;
    
    import org.mensxmachina.graph.*;

    load('alarm_bayesnet', 'BayesNet');
    
    % count variables
    nVars = length(BayesNet.varNames);
    
    % create DAG d-separation CI test p-value estimator and dummy RC applier
    CITPValueEstimator = dagcitpvalueestimator(BayesNet.structure);
    CITRCApplier = dummycitrcapplier(nVars);
    
    % count link-absence hypotheses
    m = nVars*(nVars - 1)/2;
    
    % set significance level
    alpha = 0.05;

    % create fixed-threshold-MTP applier
    MtpApplier = fixedthresholdapplier(m, alpha);
    
    skeletonLearner = mtpcskeletonlearner(CITRCApplier, CITPValueEstimator, MtpApplier);
    
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