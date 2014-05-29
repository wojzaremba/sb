%% Creating, viewing and sampling a Bayesian network
% This demo illustrates the creation, viewing and sampling of the example
% _sprinkler_ Bayesian network from _Artificial Intelligence: A Modern
% Approach (1st Edition)_. Terms _variable_ and _node_ are used
% interchangeably.

%% Creating the structure
% The first component of a Bayesian network is its _structure_, a directed
% acyclic graph (DAG). In MATLAB(R), graphs are represented as sparse
% matrices. A nonzero element in the matrix denotes an edge in the graph.
% We create the structure of the sprinkler network. The structure has 4
% nodes and edges 1->2, 1->3, 2->4 and 3->4.

% create structure
structure = sparse([1 1 2 3], [2 3 4 4], 1, 4, 4);

%% Creating the conditional probability distributions
% The second component of a Bayesian network is the _conditional
% probability distributions_ (CPDs) of the nodes given values of their
% parents. In general, a CPD is the probability distribution of a set of
% _response_ variables given values of a set of _explanatory_ variables.
% The CPDs in a Bayesian network are CPDs of a single response variable,
% the explanatory variables being the parents of that variable.
%
% The variables of the sprinkler network are _cloudy_, _sprinkler_, _rain_,
% and _wetGrass_. All of them are binary variables taking values _false_ and
% _true_. We represent these values by Statistics Toolbox(TM) _categorical
% arrays_ with levels _false_ and _true_.
%
% We create a _tabular CPD_ for each variable. Tabular CPDs are encoded as
% tables. For each tabular CPD, we supply the variable names, the variable
% values, the _CPD-variable types_ and the values of the CPD. A
% CPD-variable type is either |Explanatory| or |Response|. The values of
% a tabular CPD are ND arrays. Each value of the ND array is the
% probability of the corresponding variable-value combination.

import org.mensxmachina.stats.cpd.cpdvartype;
import org.mensxmachina.stats.cpd.tabular.tabcpd;

% create variable values -- same for all variables
varValues = nominal([1; 2], {'false', 'true'});

% create CPDs

E = cpdvartype.Explanatory;
R = cpdvartype.Response;

cloudyCpd = tabcpd(...
    {'cloudy'}, ...
    {varValues}, ...
    R, ...
    reshape([0.5 0.5], 2, 1))

sprinklerCpd = tabcpd(...
    {'cloudy', 'sprinkler'}, ...
    {varValues, varValues}, ...
    [E R], ...
    reshape([0.5 0.5; 0.9 0.1], 2, 2))

rainCpd = tabcpd(...
    {'cloudy', 'rain'}, ...
    {varValues, varValues}, ...
    [E R], ...
    reshape([0.8 0.2; 0.2 0.8], 2, 2))

wetGrassCpd = tabcpd(...
    {'sprinkler', 'rain', 'wetGrass'}, ...
    {varValues, varValues, varValues}, ...
    [E E R], ...
    reshape([1 0.1 0.1 0.01 0 0.9 0.9 0.99], 2, 2, 2))

% put them all together
cpd = {cloudyCpd, sprinklerCpd, rainCpd, wetGrassCpd};

%% Creating the network
% We create the sprinkler network by supplying its structure and its CPDs.

import org.mensxmachina.pgm.bn.bayesnet;

% create Bayesian network
BayesNet = bayesnet(structure, cpd);

%% Viewing the structure
% Bayesian networks are viewed by _Bayesian network viewers_. We use a
% _biograph-based Bayesian network viewer_, which uses a Bioinformatics
% Toolbox(TM) biograph, to view the structure of the sprinkler network.

import org.mensxmachina.pgm.bn.viewers.biograph.biographbayesnetviewer;

% create Bayesian network Viewer
Viewer = biographbayesnetviewer(BayesNet);

% view the Bayesian network structure
Viewer.viewbayesnetstructure();

%% Sampling the network
% A Bayesian network is itself a CPD and can be sampled. We sample a CPD by
% supplying a Statistics Toolbox(TM) dataset array containing values of
% the explanatory variables of the CPD. The sample is a dataset containing
% values for the response variables of the CPD.
%
% We get a random sample with 10 observations from the sprinkler network by
% supplying an empty 10-by-0 dataset array, since there are no explanatory
% variables in Bayesian networks.

% get a random sample from the Bayesian network
D = random(BayesNet, dataset.empty(10, 0))