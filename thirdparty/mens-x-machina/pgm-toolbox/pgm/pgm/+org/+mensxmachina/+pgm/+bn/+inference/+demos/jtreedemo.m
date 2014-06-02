%% Bayesian network inference using the junction-tree algorithm
% This demo illustrates Bayesian network inference using the junction-tree
% algorithm. The example is due to Kevin Murphy
% (http://bnt.googlecode.com/svn/trunk/docs/usage.html) and uses the
% _sprinkler_ Bayesian network from _Artificial Intelligence: A Modern
% Approach (1st Edition)_.

%% Creating the network
% First we create the sprinkler network.

import org.mensxmachina.pgm.bn.tabular.sprinkler;

% create the network
BayesNet = org.mensxmachina.pgm.bn.tabular.sprinkler

%% Viewing the network structure
% We view the network structure.

import org.mensxmachina.pgm.bn.viewers.biograph.biographbayesnetviewer;

% create Bayesian network Viewer
Viewer = biographbayesnetviewer(BayesNet);

% view the network structure
Viewer.viewbayesnetstructure();

%% Creating an inference Engine
% Probabilistic inference is performed by an "inference Engine". An
% inference Engine computes the marginal probability distribution of
% members of a set of variables given evidence.
% 
% The junction-tree inference Engine needs to be supplied a Bayesian
% network, and the evidence and weight for each variable in the network.
%
% The evidence for each variable is a likelihood, which is a special case
% of a potential. A potential over a set of variables is a function that
% maps each variable-value combination to a nonnegative number. A
% likelihood is a potential over a single variable that maps each variable
% value to a number in range [0, 1]. A likelihood of 1 for a single value x
% of variable X and 0 for all the other values of X encodes the fact that X
% = x. A likelihood of 1 for every value of X denotes that the value of X
% is unknown.
%
% The likelihood of each variable must be compatible with the CPD of that
% variable in the network. Since all CPDs in our network are tabular CPDs,
% we create a tabular likelihood for each variable. Our evidence encodes
% the fact that wetGrass = true and the values of cloudy, sprinkler and
% rain are unknown.
% 
% For finite-domain variables, the weight of a variable is the number of
% values of that variable.

import org.mensxmachina.stats.cpd.tabular.tabpotential;    
import org.mensxmachina.pgm.bn.inference.jtree.jtreeinfengine;

% create variable values -- same for all variables
varValues = nominal([1; 2], {'false', 'true'}, [1 2]);

% create evidence for each variable
CloudyEvidence = tabpotential({'cloudy'}, {varValues}, [1; 1])
SprinklerEvidence = tabpotential({'sprinkler'}, {varValues}, [1; 1])
RainEvidence = tabpotential({'rain'}, {varValues}, [1; 1])
WetGrassEvidence = tabpotential({'wetGrass'}, {varValues}, [0; 1])  

% put the evidence together
evidence = {CloudyEvidence, SprinklerEvidence, RainEvidence, WetGrassEvidence};

% create variable weights - same for all variables
varWeights = [2 2 2 2];

% create the Engine
Engine = jtreeinfengine(BayesNet, evidence, varWeights);

%% Computing a marginal probability distribution
% We compute Pr(sprinkler|wetGrass = true), that is, the probability of the
% sprinkler being on when the grass is wet.

% get the marginal distribution of variable 2 (sprinkler)
M = marginal(Engine, 2)

%% Updating the evidence
% We update the evidence of the Engine to encode the fact that also rain =
% true.

% change the evidence for variable 3 (rain)
evidence{3} = tabpotential({'rain'}, {varValues}, [0; 1]);

% update the evidence
Engine.evidence = evidence;

%% Computing the marginal probability distribution given the new evidence
% Finally, we compute Pr(sprinkler|wetGrass = true, rain = true), that is,
% the probability of the sprinkler being on when the grass is wet and it is
% raining. We see that the fact that it is raining has reduced the
% probability that the sprinkler is on.

% get the new marginal distribution of variable 2 (sprinkler)
M = marginal(Engine, 2)