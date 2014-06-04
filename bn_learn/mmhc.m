function [G, T] = mmhc(data, arity)

tic; 
nvars = size(data, 2);
nstates = arity * ones(1, nvars);

import org.mensxmachina.stats.tests.ci.kci.kcipvalueestimator;
import org.mensxmachina.stats.tests.ci.dummycitrcapplier; 
import org.mensxmachina.pgm.bn.learning.cb.cit.citdsepdeterminer; 
import org.mensxmachina.pgm.bn.learning.cb.lg.gl.mm.cit.citcacalculator;
import org.mensxmachina.pgm.bn.learning.cb.lg.gl.mm.mmlglearner;

% create CIT-p-value estimator
CITPValueEstimator = kcipvalueestimator(data);

% create CIT-RC applier
CITRCApplier = dummycitrcapplier(size(data,2));

% create d-separation determiner
CITDSepDeterminer = citdsepdeterminer(CITRCApplier, CITPValueEstimator);

% create CA calculator
CITCACalculator = citcacalculator(CITRCApplier, CITPValueEstimator);

% create max-min local-to-global learner without symmetry correction
MMLGLearner = mmlglearner(...
    CITDSepDeterminer, ...
    CITCACalculator, ...
    'maxSepsetCard', min(10, nvars - 2), ...
    'symCorrEnabled', false);

% learn skeleton
skeleton = MMLGLearner.learnskeleton();

import org.mensxmachina.pgm.bn.learning.structure.sns.local.bdeu.bdeulocalscorer;
import org.mensxmachina.pgm.bn.learning.structure.sns.local.hc.hillclimber;

if ~is_discrete(data, arity)
    data = discretize_data(data, arity);
end

% create local scorer
LocalScorer = bdeulocalscorer(data, nstates);

% create candidate parent matrix
cpm = tril(skeleton + skeleton');

% create hill climber
HillClimber = hillclimber(LocalScorer, 'CandidateParentMatrix', cpm);

% learn structure
structure = HillClimber.learnstructure();
G = full(structure);
T = toc;
