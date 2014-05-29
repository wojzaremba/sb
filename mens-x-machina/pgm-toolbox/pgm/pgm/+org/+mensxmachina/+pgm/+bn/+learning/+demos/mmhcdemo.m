%% Applying the MMPC, MMPC-skeleton and MMHC algorithms
% This demo illustrates the process of applying the _MMPC_, _MMPC-skeleton_
% and _MMHC_ algorithm to learn the parents and children of a node, the
% skeleton, and the stucture, respectively, of the _Alarm_ Bayesian
% network. Terms _variable_ and _node_ are used interchangeably.

%% Creating a max-min local-to-global learner
% MMPC is applied by a _max-min local-to-global learner_. A max-min
% local-to-global learner uses a _d-separation determiner_ and a
% _conditional-association calculator_. A d-separation determiner
% determines d-separation relationships among a set of variables. A
% conditional association (CA) calculator calculates a measure of
% association of pairs of variables in a set given subsets of the rest
% variables in the set.
% 
% Here we use a conditional-independence-test-based d-separation determiner
% and a conditional-independence-test-based conditional-association
% calculator, which determines d-separations and calculates conditional
% associations, respectively, by performing conditional independence tests
% (CITs). Both use a _conditional-independence-test-reliability-criterion
% applier_ and a _conditional-independence-test-p-value estimator_. A
% CIT-reliability-criterion applier determines, for a set of variables, if
% a CI test involving variables of the set is reliable according to a
% reliability criterion (RC). A CIT-p-value estimator estimates, for a set
% of variables, the p-value of CI tests involving variables of the set.
% 
% Here we use a _heuristic-power-rule applier_, which applies the
% _heuristic power rule_ reliability criterion, and _G-test applier_, which
% applies the G CI test. Both use a sample from the joint probability
% distribution of a set of finite-domain variables. The sample is in the
% form of linear indices of variable values (that is, for a sample |d|,
% |d(i, j) = k| denotes that, in the |i|-th observation, the |j|-th
% variable takes its |k|-th value) and is accompanied by the number of
% values in the domain of each variable in the set.
%
% We load a sample from the _Alarm_ network. The sample is a Statistics
% Toolbox(TM) _dataset array_ with _categorical_ variables. We get the
% number of values for each variable by calling function
% |org.mensxmachina.stats.array.datasetvarnvalues| on the sample. We
% convert the sample to linear indices simply by calling its method
% |double|.
%
% To speed-up the search for sepsets, we limit the maximal sepset
% cardinality to 10.

import org.mensxmachina.stats.array.datasetvarnvalues;

import org.mensxmachina.stats.tests.ci.chi2.gtestpvalueestimator;
import org.mensxmachina.stats.tests.ci.chi2.heuristic.heuristicapplier; 

import org.mensxmachina.pgm.bn.learning.cb.cit.citdsepdeterminer; 
import org.mensxmachina.pgm.bn.learning.cb.lg.gl.mm.cit.citcacalculator;

import org.mensxmachina.pgm.bn.learning.cb.lg.gl.mm.mmlglearner;

% load a sample from the Alarm network
load('alarm_bayesnet_sample', 'Sample');

% get number of values of each variable in the sample
varNValues = datasetvarnvalues(Sample);

% convert sample to double
sample = double(Sample);

% create CIT-p-value estimator
CITPValueEstimator = gtestpvalueestimator(sample, varNValues);

% create CIT-RC applier
CITRCApplier = heuristicapplier(sample, varNValues);

% create d-separation determiner
CITDSepDeterminer = citdsepdeterminer(CITRCApplier, CITPValueEstimator);

% create and CA calculator
CITCACalculator = citcacalculator(CITRCApplier, CITPValueEstimator);

% create max-min local-to-global learner
MMLGLearner = mmlglearner(...
    CITDSepDeterminer, CITCACalculator, 'maxSepsetCard', 10);

%% Learning the set of parents and children of a node
% Now we learn the set of parents and children of node 37.

% learn parents and children of node 37
pc = MMLGLearner.learnpc(37)

%% Comparing the learned parents and children set with the true ones
% Now we compare the learned parents and children with the true ones. For a
% given node, the task of learning its parents and children can be viewed
% as a binary classification task, where each other node is classified as
% either parent or child, or not. First we use Bioinformatics Toolbox(TM)
% function |classperf| to measure the classification performance. Then we
% use Neural Network Toolbox(TM) function |plotconfusion| to plot the
% confusion matrix. We see that we learn the parents and children of node
% 37 correctly.

% load Alarm network
load('alarm_bayesnet', 'BayesNet');

% create true labels
skeleton_true = BayesNet.skeleton(); % get true skeleton
truelabels = full(skeleton_true(37, :) | skeleton_true(:, 37)');
truelabels(37) = [];

% create classifier output
classout = zeros(1, length(BayesNet.varNames));
classout(pc) = 1;
classout(37) = [];

% get classification performance
cp = classperf(truelabels, classout, 'Positive', 1, 'Negative', 0);

% print sensitivity and specificity
fprintf('\nSensitivity = %.2f%%\n', cp.sensitivity*100);
fprintf('\nSpecificity = %.2f%%\n', cp.specificity*100);

% plot confusion matrix
%plotconfusion(truelabels, classout);

%% Learning the skeleton of the network
% A max-min local-to-global learner also applies MMPC-skeleton to learn the
% skeleton of the network. We learn the skeleton of the network. Output
% |skeleton| is a sparse matrix representing an undirected graph. A nonzero
% element in the lower triangle of the matrix denotes an edge in the graph.

% learn skeleton
skeleton = MMLGLearner.learnskeleton()

%% Comparing the learned skeleton with the true one
% Now we compare the learned skeleton with the true one. Skeleton
% identification can be viewed as binary classification where each pair of
% nodes is classified as link (positive) or non-link (negative). First we
% use |classperf| to measure the classification performance. Then we use
% |plotconfusion| to plot the confusion matrix.

import org.mensxmachina.graph.undigraphmat2vec;

% create true labels
truelabels = undigraphmat2vec(BayesNet.skeleton())';

% create classifier output
classout = undigraphmat2vec(skeleton)';

% get classification performance
cp = classperf(truelabels, classout, 'Positive', 1, 'Negative', 0);

% print sensitivity and specificity
fprintf('\nSensitivity = %.2f%%\n', cp.sensitivity*100);
fprintf('\nSpecificity = %.2f%%\n', cp.specificity*100);

% plot confusion matrix
%plotconfusion(truelabels, classout);

%% Learning the skeleton of the network without symmetry correction
% The first phase of MMHC is to apply MMPC-skeleton without symmetry
% correction. To this end, we create a max-min local-to-global learner
% without symmetry correction and use it to the learn the skeleton.

% create max-min local-to-global learner without symmetry correction
MMLGLearner = mmlglearner(...
    CITDSepDeterminer, ...
    CITCACalculator, ...
    'maxSepsetCard', 10, ...
    'symCorrEnabled', false);

% learn skeleton
skeleton = MMLGLearner.learnskeleton();

%% Creating a hill climber
% The second phase of MMHC is hill-climbing. Hill climbing is performed by
% a _hill-climber_, which uses a _local scorer_. A local scorer scores, for
% a set of variables, the family of a variable (that is, the variable
% itself and its parents) in a Bayesian network representing the joint
% probability distribution of the variables.
%
% MMHC uses the _BDeu_ score, therefore we use a _BDeu local scorer_. A
% BDeu local scorer needs to be supplied a sample from the network in the
% same way as the p-value estimator and the RC applier above.
%
% By default, a hill climber performs an unconstrained search in the space
% of DAGs. If a _candidate parent matrix_ is supplied, however, the search
% is constrained to those DAGs with the set of parents of each node being a
% subset of the set of candidate parents of that node, as specified in the
% matrix. For a candidate parent matrix |cpm|, a nonzero |cpm(i, j)|
% indicates that node |i| is a candidate parent of node |j|.

import org.mensxmachina.pgm.bn.learning.structure.sns.local.bdeu.bdeulocalscorer;

import org.mensxmachina.pgm.bn.learning.structure.sns.local.hc.hillclimber;

% create local scorer
LocalScorer = bdeulocalscorer(sample, varNValues);

% create candidate parent matrix
cpm = tril(skeleton + skeleton');

% create hill climber
HillClimber = hillclimber(LocalScorer, 'CandidateParentMatrix', cpm);

%% Learning the structure of the network
% Finally, we learn the structure of the network.

% learn structure
structure = HillClimber.learnstructure()
