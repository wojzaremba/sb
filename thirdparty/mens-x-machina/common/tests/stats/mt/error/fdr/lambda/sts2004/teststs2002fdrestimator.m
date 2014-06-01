classdef teststs2002fdrestimator < TestCase

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
    
    lambda
    
    lambdaFdrStarEstimator
    lambdaFdrEstimator

    m
    p
    t

end

methods

function Obj = teststs2002fdrestimator(name)

    import org.mensxmachina.stats.mt.error.fdr.lambda.sts2004.sts2004fdrestimator;
    import org.mensxmachina.stats.mt.error.fdr.lambda.storey2002.storey2002fdrestimator;

    Obj = Obj@TestCase(name);

    Obj.m = 8;

    Obj.p = [0 0.001 0.01 0.01 0.05 0.1 0.5 1]';
    Obj.p = Obj.p(randperm(length(Obj.p)));
    
    Obj.t = [0 0.005 0.03 0.07 0.7 1]';
    tOrder = randperm(length(Obj.t));
    Obj.t = Obj.t(tOrder);
    
    Obj.lambda = 0.5;

    Obj.lambdaFdrStarEstimator = sts2004fdrestimator(Obj.m, Obj.lambda);
    Obj.lambdaFdrEstimator = storey2002fdrestimator(Obj.m, Obj.lambda);

end

function testlambda(Obj)

    clc;

    % test 0
    assertExceptionThrown(@set0, 'MATLAB:assert:failed');
    function set0()
        org.mensxmachina.stats.mt.error.fdr.lambda.sts2004.sts2004fdrestimator(Obj.m, 0);
    end

end

function testcmpwithstorey2002(Obj)

    clc;
    
    % FDR*_lambda
    lambdaFdrStar = Obj.lambdaFdrStarEstimator.estimateerror(Obj.p, Obj.t);
    lambdaFdrStarPi0 = (sum(Obj.p > Obj.lambda) + 1)/((1 - Obj.lambda)*Obj.m);

    % FDR_lambda
    lambdaFdr = Obj.lambdaFdrEstimator.estimateerror(Obj.p, Obj.t);
    lambdaFdrPi0 = sum(Obj.p > Obj.lambda)/((1 - Obj.lambda)*Obj.m);

    % modify FDR_lambda to create FDR*_lambda
    lambdaFdrModified = (lambdaFdrStarPi0/lambdaFdrPi0)*lambdaFdr;
    lambdaFdrModified(Obj.t > Obj.lambda) = 1;
    
    assertEqual(lambdaFdrStar, lambdaFdrModified);

end

end

end