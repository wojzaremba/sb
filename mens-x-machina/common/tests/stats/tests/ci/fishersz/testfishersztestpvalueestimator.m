classdef testfishersztestpvalueestimator < TestCase
%TESTFISHERZCITER FISHERSZTESTPERFORMER Performer cases
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

properties(Access = private)
    
    sample
    Performer
    
end

methods

function Obj = testfishersztestpvalueestimator(name)

    clc;

    import org.mensxmachina.stats.tests.ci.fishersz.fishersztestpvalueestimator;

    Obj = Obj@TestCase(name);

    % create dataset

    var1 = randn(10000, 1);
    var2 = randn(10000, 1); % I(1;2)
    var3 = var1 + 1; % ~I(1;3)
    var4 = var1/2; % ~I(1;3) but I(1;3|4)
    var5 = var1 + var2; % I(1;2) but ~I(1;2|5)

    Obj.sample = [var1 var2 var3 var4 var5];

    Obj.Performer = fishersztestpvalueestimator(Obj.sample);

end

function testi12givenempty(Obj)
    p = citpvalue(Obj.Performer, 1, 2, zeros(1, 0));
    assertTrue(p > 0.05);
end

function testd13givenempty(Obj)
    p = citpvalue(Obj.Performer, 1, 3, zeros(1, 0));
    assertTrue(p <= 0.05);
end

function testi13given4(Obj)
    p = citpvalue(Obj.Performer, 1, 3, 4);
    assertTrue(isnan(p));
end

function testd12given5(Obj)
    p = citpvalue(Obj.Performer, 1, 2, 5);
    assertTrue(p <= 0.05);
end

function testcmpwithce(Obj)
    
    % compare with Causal Explorer's FISHER()

    clc;
    
    import org.mensxmachina.stats.tests.ci.fishersz.fishersztestpvalueestimator;

    j1 = 1;
    j2 = 2;
    j3 = 5;

    alpha = 0.05;

    ss = [100 1000 10000];
    %ss = 10000;
    numSS = numel(ss);
    numRepeats = 100;

    time_ss = zeros(1, numSS);
    time_ss_ce = zeros(1, numSS);

    for i=1:numSS

        sample = Obj.sample(1:ss(i), :);
        
        Performer = fishersztestpvalueestimator(sample);

        start = cputime;

        for j=1:numRepeats

            p = citpvalue(Performer, j1, j2, j3);

        end

        time_ss(i) = cputime - start;

        start = cputime;

        for j=1:numRepeats

            p_ce = fisher(j1, j2, j3, sample);

        end

        time_ss_ce(i) = cputime - start;

        tol = 1e-6;

        assertElementsAlmostEqual(p, p_ce, 'absolute', tol);


    end

    disp('MxM x faster than CE');
    ((time_ss_ce - time_ss) ./ time_ss_ce)


end

end

end 
