classdef testhillclimber < TestCase
%TESTHC mmpcskeleton + hc test cases

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
    
    varNValues
    sample
    
    varNames
    LocalScorer
    
    plainHillClimber
    constrainedHillClimber

end

methods

function Obj = testhillclimber(name)

    import org.mensxmachina.stats.array.datasetvarnvalues;
    import org.mensxmachina.pgm.bn.learning.structure.sns.local.bdeu.bdeulocalscorer;
    import org.mensxmachina.pgm.bn.learning.structure.sns.local.hc.hillclimber;

    Obj = Obj@TestCase(name);
    
    load('alarm_bayesnet_sample', 'Sample'); % load sample
    load('alarm_bayesnet', 'BayesNet');
    
    Obj.bayesNet = BayesNet;
    Obj.varNValues = datasetvarnvalues(Sample);
    Obj.sample = double(Sample(1:1000, :)); % select first 1000 samples and convert to double
    
    Obj.LocalScorer = bdeulocalscorer(Obj.sample, Obj.varNValues);
    
    Obj.plainHillClimber = hillclimber(Obj.LocalScorer);
    
    % create candidate parent matrix
    skeleton = Obj.bayesNet.skeleton();
    cpm = tril(skeleton + skeleton');
    
    Obj.constrainedHillClimber = hillclimber(Obj.LocalScorer, 'CandidateParentMatrix', cpm);

end

function testplainhc(Obj)

    clc;
    
    import org.mensxmachina.graph.undigraphmat2vec;
    
    trueSkeleton = Obj.bayesNet.skeleton();
    
    [structure1 logScore1] = Obj.plainHillClimber.learnstructure();
    skeleton1 = tril(structure1 + structure1');
    
%     % save
%     
%     structure = structure1;
%     logScore = logScore1;
%     
%     save('testhillclimber_testplainhc', 'structure', 'logScore');

    % compare with saved
    
    load('testhillclimber_testplainhc', 'structure', 'logScore');
    
    assertEqual(structure, structure1);
    assertEqual(logScore, logScore1);

    % classification performance
    
    trueSkeletonVector = undigraphmat2vec(trueSkeleton);
    skeleton1Vector = undigraphmat2vec(skeleton1);
    
    cp = classperf(trueSkeletonVector, skeleton1Vector, 'Positive', 1, 'Negative', 0);
    
    cp.sensitivity
    1 - cp.PositivePredictiveValue

end

function testconstrainedhc(Obj)

    clc;
    
    import org.mensxmachina.graph.undigraphmat2vec;
    
    trueSkeleton = Obj.bayesNet.skeleton();
    
    [structure1 logScore1] = Obj.constrainedHillClimber.learnstructure();
    skeleton1 = tril(structure1 + structure1');
    
%     % save
%     
%     structure = structure1;
%     logScore = logScore1;
%     
%     save('testhillclimber_testconstrainedhc', 'structure', 'logScore');
    
    % compare with saved
    
    load('testhillclimber_testconstrainedhc', 'structure', 'logScore');
    
    assertEqual(structure, structure1);
    assertEqual(logScore, logScore1);

    % classification performance
    
    trueSkeletonVector = undigraphmat2vec(trueSkeleton);
    skeleton1Vector = undigraphmat2vec(skeleton1);
    
    cp = classperf(trueSkeletonVector, skeleton1Vector, 'Positive', 1, 'Negative', 0);
    
    cp.sensitivity
    1 - cp.PositivePredictiveValue

end

function testcmpconstrainedhcwithce(Obj)

    clc;
    
    import org.mensxmachina.graph.undigraphmat2vec;
    import org.mensxmachina.pgm.bn.learning.structure.sns.local.hc.hillclimber;

    trueSkeleton = Obj.bayesNet.skeleton();

    % convert to Causal Explorer data
    data = Obj.sample - 1;
    
    tic;
    
    [ceG ceLogScore num_stats cpTime initialCESkeleton] = ...
        Causal_Explorer('MMHC', data, Obj.varNValues, 'MMHC', [], 10, 'BDeu');
    
    ceTime = toc;
    
    ceTime = ceTime - cpTime;
    
    initialCESkeleton = sparse(initialCESkeleton);
    
    save('testhillclimber_testcmpconstrainedhcwithce', 'ceG', 'ceLogScore', 'ceTime', 'initialCESkeleton');
    

    load('testhillclimber_testcmpconstrainedhcwithce', 'ceG', 'ceLogScore', 'ceTime', 'initialCESkeleton');
    
    ceSkeleton = tril(ceG + ceG');

    plainHillClimber = hillclimber(Obj.LocalScorer, 'CandidateParentMatrix', initialCESkeleton);
    
    tic;
    
    [structure logScore] = plainHillClimber.learnstructure();
    
    time = toc;
    
    skeleton = tril(structure + structure');

    % print CE performance
    disp('CE');
    ceTime
    ceLogScore
    trueSkeletonVector = undigraphmat2vec(trueSkeleton);
    skeleton_ce_vector = undigraphmat2vec(ceSkeleton);
    cp = classperf(trueSkeletonVector, skeleton_ce_vector, 'Positive', 1, 'Negative', 0);
    cp.sensitivity
    1 - cp.PositivePredictiveValue

    % print PGM performance
    disp('PGM');
    time
    logScore
    trueSkeletonVector = undigraphmat2vec(trueSkeleton);
    skeletonVector = undigraphmat2vec(skeleton);
    cp = classperf(trueSkeletonVector, skeletonVector, 'Positive', 1, 'Negative', 0);
    cp.sensitivity
    1 - cp.PositivePredictiveValue

    disp('diff');
    structure ~= ceG

end

end

end