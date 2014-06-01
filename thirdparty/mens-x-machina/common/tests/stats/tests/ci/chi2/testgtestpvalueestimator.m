classdef testgtestpvalueestimator < TestCase
%TESTGCIT GCIT test cases
%   Note: Requires Causal Explorer to be in the path.

% Copyright 2010-2012 Mens X Machina
% 
% This file is part of Mens X Machina Common Toolbox.
% 
% Mens X Machina Common Toolbox is free software: you can redistribute it
% and/or modify it under the terms of the GNU General Public License
% alished by the Free Software Foundation, either version 3 of the License,
% or (at your option) any later version.
% 
% Mens X Machina Common Toolbox is distributed in the hope that it will be
% useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
% Public License for more details.
% 
% You should have received a copy of the GNU General Public License along
% with Mens X Machina Common Toolbox. If not, see
% <http://www.gnu.org/licenses/>.

properties

    Estimator

    sample
    
    varNValues
    alpha

end

methods

function Obj = testgtestpvalueestimator(name)

    clc;

    import org.mensxmachina.stats.tests.ci.chi2.gtestpvalueestimator;

    Obj = Obj@TestCase(name);

    % create dataset

    var1 = randi(2, 10000, 1);
    var2 = randi(2, 10000, 1); % I(1;2)
    var3 = randi(2, 10000, 1); % I(1;2)
    var4 = var1 + var2 - 1; % I(1;2)

    Obj.sample = [var1 var2 var3 var4];
    Obj.varNValues = [2 2 2 4];
    
    Obj.Estimator = gtestpvalueestimator(Obj.sample, Obj.varNValues);
    
    Obj.alpha = 0.05;

end

function testi12givenempty(Obj)
    clc;
    p = Obj.Estimator.citpvalue(1, 2, zeros(1, 0));
    assertTrue(p > 0.05);
end

function testd11givenempty(Obj)
    clc;
    p = Obj.Estimator.citpvalue(1, 1, zeros(1, 0));
    p
    assertTrue(p <= 0.05)
end

function testi12given1(Obj) % j3 exactly determines j1
    
    clc;
    
    p = Obj.Estimator.citpvalue(1, 2, 1);
    
    assertEqual(p, 1);
    
end

function testi11given1(Obj) % j3 exactly determines both j1 and j2
    
    clc;
    
    p = Obj.Estimator.citpvalue(1, 1, 1);
    assertEqual(p, 1);
    
end

function testd12given3(Obj)
    clc;
    p = Obj.Estimator.citpvalue(1, 2, 3);
    assertTrue(p > 0.05);
end

function testd12given4(Obj)
    clc;
    p = Obj.Estimator.citpvalue(1, 2, 4);
    assertTrue(p <= 0.05)
end

function testcmpwithpearsonchisquaredtesterci(Obj)
    
    import org.mensxmachina.stats.tests.ci.chi2.pearsonschi2testpvalueestimator;

    pearsonsPerformer = pearsonschi2testpvalueestimator(Obj.sample, Obj.varNValues);

    p_g2 = Obj.Estimator.citpvalue(1, 2, zeros(1, 0));
    p_chi2 = pearsonsPerformer.citpvalue(1, 2, zeros(1, 0));
    tol = 1e-5;
    p_g2
    p_chi2
    assertElementsAlmostEqual(p_g2, p_chi2, 'absolute', tol);

end

% function testddonhailfinder(Obj)
%     
%     % Depends on bayesnet
% 
%     clc;
%     
%     import org.mensxmachina.stats.array.datasetvarnvalues;
%     import org.mensxmachina.stats.tests.ci.chi2.gtestpvalueestimator;
% 
%     load hailfinder_bnet_sample_1 sample;
%     load hailfinder_bnet bnet;
%     
%     varNValues = datasetvarnvalues(sample);
%     sample = double(sample);
%     
%     performer = gtestpvalueestimator(sample, varNValues);
%     ddPerformer = gtestpvalueestimator(sample, varNValues, 'determinismDetectionEnabled', true);
% 
%     j1 = 47; % child of #27
%     j2 = 41; % deterministic child of #27
%     j3 = 27;
%     
%     p = performer.citpvalue(j1, j2, j3);
%     assert(isnan(p));
%     
%     p = ddPerformer.citpvalue(j1, j2, j3);
%     assertTrue(p > 0.05);
%     assertEqual(p, 1);  
% 
%     j1 = 56; % child of #27
%     j2 = 27;
%     j3 = 41; % deterministic child of #27
% 
%     bnet.cpd{41}.values % #41 is a damn copy of #27! fffffffuuuuuuuuuuuu
% 
%     bnet.cpd{5}.values % and #5 a copy of 4
%     bnet.cpd{22}.values % and #22 a copy of 21 (with different order of levels)
% 
%     p = performer.citpvalue(j1, j2, j3);
%     assert(isnan(p));
%     
%     p = ddPerformer.citpvalue(j1, j2, j3);
%     assertTrue(p > 0.05);
%     assertEqual(p, 1);
% 
% end

function testcmpwithce(Obj)
    
    % compare with Causal Explorer's G2TEST_2()

    clc;

    import org.mensxmachina.stats.tests.ci.chi2.gtestpvalueestimator;

    j1 = 1;
    j2 = 2;
    j3 = 4;

    n = [100 1000 10000];
    numN = numel(n);
    numRepeats = 100;

    time_ss = zeros(1, numN);
    time_ss_ce = zeros(1, numN);

    for i = 1 : numN % for each sample size

        sample_i = Obj.sample(1:n(i), :);
        sample_i_ce = sample_i - 1;

        start = cputime;
        
        Estimator = gtestpvalueestimator(sample_i, Obj.varNValues);

        for j=1:numRepeats
            
            [p g2] = Estimator.citpvalue(j1, j2, j3);

        end

        time_ss(i) = cputime - start;

        start = cputime;

        for j=1:numRepeats

            [p_ce, G2_ce, exit_flag] = g2test_2(j1, j2, j3, sample_i_ce, Obj.varNValues);

        end
        
        time_ss_ce(i) = cputime - start;

        if isnan(p)

            disp('p-value = NaN');

%            assertTrue( exit_flag == 0 );
 %           assertTrue( isnan(p_ce) );

        else

            tol = 1e-6;

            assertElementsAlmostEqual(p, p_ce, 'absolute', tol);
            assertElementsAlmostEqual(g2, G2_ce, 'absolute', tol);

        end

    end

    disp('MxM x faster than CE');
    ((time_ss_ce - time_ss) ./ time_ss_ce)


end

end

end