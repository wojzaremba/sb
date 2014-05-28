classdef testbdeulocalscorer < TestCase

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
% [1] David Heckerman, Dan Geiger, and David M. Chickering. Learning
%     bayesian networks: The combination of knowledge and statistical data.
%     In KDD Workshop, pages 85-“96, 

properties
        
    bayesNet
    varNValues
    sample
    xInd

    equivalentSampleSize
    
    LocalScorer

end

methods

function Obj = testbdeulocalscorer(name)

    clc;
    
    import org.mensxmachina.stats.array.datasetvarnvalues;
    import org.mensxmachina.pgm.bn.learning.structure.sns.local.bdeu.bdeulocalscorer;

    Obj = Obj@TestCase(name);

    load('alarm_bayesnet', 'BayesNet');
    load('alarm_bayesnet_sample', 'Sample');

    Obj.bayesNet = BayesNet;
    Obj.varNValues = datasetvarnvalues(Sample);
    Obj.sample = double(Sample(1:100, :)); % keep first 100 observations and convert to double
    Obj.xInd = 26;
    
    Obj.equivalentSampleSize = 10;

    Obj.LocalScorer = bdeulocalscorer(Obj.sample, Obj.varNValues, Obj.equivalentSampleSize);

end

function testlikelihoodtoy(Obj)
    
    % [1] p.221
    
    clc; 
    Obj.equivalentSampleSize = 12;
    P = [1/4 1/6; 1/4 1/3];

    v = [1 1; 1 2];
    dc = [2 2];
    Param = struct('equivalentSampleSize', Obj.equivalentSampleSize);

    [nObs nVars] = size(v);

    % xInd = 1
    xInd = 1;
    parents = [];

    % compute counts
    Obj.equivalentSampleSize = accumarray(v(:, xInd), ones(1, nObs), [dc(xInd) 1]);
    Obj.equivalentSampleSize = Obj.equivalentSampleSize';

    numParentLevels = prod(dc(parents));

    N_ijk = reshape(Obj.equivalentSampleSize, numParentLevels, dc(xInd));

    N_ij = sum(N_ijk, 2);

    N_prime_ijk = Param.equivalentSampleSize*sum(P, 2)';
    N_prime_ij = sum(N_prime_ijk, 2);

    % compute log likelihood
    likelihood1 = sum(gammaln(N_prime_ij) - gammaln(N_prime_ij + N_ij)) + ...
                  sum(sum(gammaln(N_prime_ijk + N_ijk) - gammaln(N_prime_ijk)));
    % xInd = 2
    xInd = 2;
    parents = 1;

    % compute counts
    Obj.equivalentSampleSize = accumarray(v(:, [parents xInd]), ones(1, nObs), dc([parents xInd]));

    numParentLevels = prod(dc(parents));

    N_ijk = reshape(Obj.equivalentSampleSize, numParentLevels, dc(xInd));

    N_ij = sum(N_ijk, 2);

    N_prime_ijk = Param.equivalentSampleSize*P;
    N_prime_ij = sum(N_prime_ijk, 2);

    % compute log likelihood
    likelihood2 = sum(gammaln(N_prime_ij) - gammaln(N_prime_ij + N_ij)) + ...
                  sum(sum(gammaln(N_prime_ijk + N_ijk) - gammaln(N_prime_ijk)));

    likelihood = likelihood1 + likelihood2;
    assertElementsAlmostEqual(likelihood, log(1/26));         

end

function testcmpwithce(Obj)

    clc;

    nObs = size(Obj.sample, 1);

    score = Obj.LocalScorer.loglocalscore(Obj.xInd, find(Obj.bayesNet.structure(:, Obj.xInd))');
    ceScore = score_node(Obj.sample', Obj.varNValues, Obj.bayesNet.structure, 'BDeu', Obj.equivalentSampleSize, 38, 26, 0);

    modifiedScore = log2(exp(score))/nObs;

    assertElementsAlmostEqual(modifiedScore, ceScore);

end

end

end