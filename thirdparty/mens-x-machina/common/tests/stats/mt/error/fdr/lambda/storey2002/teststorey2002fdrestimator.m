classdef teststorey2002fdrestimator < TestCase

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

    fdrEstimator
    lambdaFdrEstimator

    m
    p
    t
    
    fdr
    lambdaFdr

    pIsLteAlpha
    lteAlphaP
    
    fdrFromLteAlphaP
    fdrFromEmptyP
    
    lambdaFdrFromLteAlphaP
    lambdaFdrFromEmptyP

end

methods

function Obj = teststorey2002fdrestimator(name)

    import org.mensxmachina.stats.mt.error.fdr.lambda.storey2002.storey2002fdrestimator;

    Obj = Obj@TestCase(name);
    
    Obj.m = 8;

    Obj.lambda = 0.5;

    Obj.fdrEstimator = storey2002fdrestimator(Obj.m);
    Obj.lambdaFdrEstimator = storey2002fdrestimator(Obj.m, Obj.lambda);

    Obj.p = [0 0.001 0.01 0.01 0.05 0.1 0.5 1]';
    Obj.p = Obj.p(randperm(length(Obj.p)));
    
    Obj.t = [0 0.005 0.03 0.07 0.7 1]';
    tOrder = randperm(length(Obj.t));
    Obj.t = Obj.t(tOrder);
    
    Obj.fdr = [8*0/1 8*0.005/2 8*0.03/4 8*0.07/5  8*0.7/7 8*1/8]';
    Obj.fdr = Obj.fdr(tOrder);
    
    lambdaPi0 = 1/((1 - Obj.lambda)*Obj.m);
    Obj.lambdaFdr = lambdaPi0*Obj.fdr;

    alpha = 0.05;
    
    Obj.pIsLteAlpha = Obj.p <= alpha;
    Obj.lteAlphaP = Obj.p(Obj.pIsLteAlpha);
    
    Obj.fdrFromLteAlphaP = [8*0/1 8*0.005/2 8*0.03/4 8*0.07/5 8*0.7/5 8*1/8]';
    Obj.fdrFromLteAlphaP = Obj.fdrFromLteAlphaP(tOrder);
    
    pi0FromEmptyP = 8/((1 - 0)*Obj.m); % 1
    Obj.fdrFromEmptyP = [0 0 0 0 0 1]';
    Obj.fdrFromEmptyP = Obj.fdrFromEmptyP(tOrder);
    
    lambdaPi0FromLteAlphaP = 3/((1 - Obj.lambda)*Obj.m);
    Obj.lambdaFdrFromLteAlphaP = lambdaPi0FromLteAlphaP*Obj.fdrFromLteAlphaP;
    
    lambdaPi0FromEmptyP = min(8/((1 - Obj.lambda)*Obj.m), 1);
    Obj.lambdaFdrFromEmptyP = (lambdaPi0FromEmptyP/pi0FromEmptyP)*Obj.fdrFromEmptyP;
    
end

function testm(Obj)

    clc;

    assertExceptionThrown(@setnonnumericm, 'MATLAB:invalidType');
    function setnonnumericm()
        org.mensxmachina.stats.mt.error.fdr.lambda.storey2002.storey2002fdrestimator('bad');
    end

    assertExceptionThrown(@setnonscalarm, 'MATLAB:expectedScalar');
    function setnonscalarm()
        org.mensxmachina.stats.mt.error.fdr.lambda.storey2002.storey2002fdrestimator([0 1]);
    end

    assertExceptionThrown(@setnegativem, 'MATLAB:expectedNonnegative');
    function setnegativem()
        org.mensxmachina.stats.mt.error.fdr.lambda.storey2002.storey2002fdrestimator(-1);
    end

    assertExceptionThrown(@setnonintegerm, 'MATLAB:expectedInteger');
    function setnonintegerm()
        org.mensxmachina.stats.mt.error.fdr.lambda.storey2002.storey2002fdrestimator(1.5);
    end

end

function testlambda(Obj)

    clc;

    assertExceptionThrown(@setnonnumericlambda, 'MATLAB:invalidType');
    function setnonnumericlambda()
        org.mensxmachina.stats.mt.error.fdr.lambda.storey2002.storey2002fdrestimator(Obj.m, 'bad');
    end

    assertExceptionThrown(@setnonscalarlambda, 'MATLAB:expectedScalar');
    function setnonscalarlambda()
        org.mensxmachina.stats.mt.error.fdr.lambda.storey2002.storey2002fdrestimator(Obj.m, [0 1]);
    end

    assertExceptionThrown(@setnonreallambda, 'MATLAB:expectedReal');
    function setnonreallambda()
        org.mensxmachina.stats.mt.error.fdr.lambda.storey2002.storey2002fdrestimator(Obj.m, 1i);
    end

    % test < 0
    assertExceptionThrown(@setnegative, 'MATLAB:expectedNonnegative');
    function setnegative()
        org.mensxmachina.stats.mt.error.fdr.lambda.storey2002.storey2002fdrestimator(Obj.m, -1);
    end

    % test 1
    assertExceptionThrown(@setgt1, 'MATLAB:notLess');
    function setgt1()
        org.mensxmachina.stats.mt.error.fdr.lambda.storey2002.storey2002fdrestimator(Obj.m, 2);
    end

end

function testestimateerror(Obj)
    
    clc;
    
    % lambda = 0
    
    % all p-values
    fdr = Obj.fdrEstimator.estimateerror(Obj.p, Obj.t);
    assertEqual(fdr, Obj.fdr);
    
    % some p-values
    fdrFromLteAlphaP = Obj.fdrEstimator.estimateerror(Obj.lteAlphaP, Obj.t);
    assertEqual(fdrFromLteAlphaP, Obj.fdrFromLteAlphaP);
    
    % no p-values
    fdrFromEmptyP = Obj.fdrEstimator.estimateerror(zeros(0, 1), Obj.t);
    assertEqual(fdrFromEmptyP, Obj.fdrFromEmptyP);
    
    % empty T
    emptyTFdr = Obj.fdrEstimator.estimateerror(Obj.p, zeros(0, 1));
    assertEqual(emptyTFdr, zeros(0, 1));
    
    % lambda
    
    % all p-values
    lambdaFdr = Obj.lambdaFdrEstimator.estimateerror(Obj.p, Obj.t);
    assertElementsAlmostEqual(lambdaFdr, Obj.lambdaFdr);
    
    % some p-values
    lambdaFdrFromLteAlphaP = Obj.lambdaFdrEstimator.estimateerror(Obj.lteAlphaP, Obj.t);
    assertElementsAlmostEqual(lambdaFdrFromLteAlphaP, Obj.lambdaFdrFromLteAlphaP);
    
    % no p-values
    lambdaFdrFromEmptyP = Obj.lambdaFdrEstimator.estimateerror(zeros(0, 1), Obj.t);
    assertEqual(lambdaFdrFromEmptyP, Obj.lambdaFdrFromEmptyP);
    
    % empty T
    emptyTLambdaFdr = Obj.lambdaFdrEstimator.estimateerror(Obj.p, zeros(0, 1));
    assertEqual(emptyTLambdaFdr, zeros(0, 1));
    
end

function testp(Obj)

    clc;

    % test validation

    assertExceptionThrown(@setnonnumericp, 'MATLAB:invalidType');
    function setnonnumericp()
        Obj.fdrEstimator.estimateerror('bad', Obj.t);
    end

    assertExceptionThrown(@setnonrealp, 'MATLAB:expectedReal');
    function setnonrealp()
        Obj.fdrEstimator.estimateerror(complex(Obj.p, zeros(size(Obj.p))), Obj.t);
    end
    
    assertExceptionThrown(@setnotcolumnp, 'MATLAB:expectedColumn');
    function setnotcolumnp()
        Obj.fdrEstimator.estimateerror(Obj.p', Obj.t);
    end
    
    assertExceptionThrown(@setlt0p, 'MATLAB:expectedNonnegative');
    function setlt0p()
        p = Obj.p;
        p(end) = -1;
        Obj.fdrEstimator.estimateerror(p, Obj.t);
    end
    
    assertExceptionThrown(@setgt1p, 'MATLAB:notLessEqual');
    function setgt1p()
        p = Obj.p;
        p(end) = 2;
        Obj.fdrEstimator.estimateerror(p, Obj.t);
    end
    
end

function testt(Obj)

    clc;

    % test validation

    assertExceptionThrown(@setnonnumerict, 'MATLAB:invalidType');
    function setnonnumerict()
        Obj.fdrEstimator.estimateerror(Obj.p, 'bad');
    end

    assertExceptionThrown(@setnonrealt, 'MATLAB:expectedReal');
    function setnonrealt()
        Obj.fdrEstimator.estimateerror(Obj.p, complex(Obj.t, zeros(size(Obj.t))));
    end
    
    assertExceptionThrown(@setnotcolumnt, 'MATLAB:expectedColumn');
    function setnotcolumnt()
        Obj.fdrEstimator.estimateerror(Obj.p, Obj.t');
    end

end

function testpfdr(Obj)

    clc;

    import org.mensxmachina.stats.mt.error.fdr.lambda.storey2002.storey2002pfdrestimator;

    % FDR
    fdr = Obj.fdrEstimator.estimateerror(Obj.p, Obj.t);

    % pFDR
    pFdrEstimator = storey2002pfdrestimator(Obj.m);
    pFdr = pFdrEstimator.estimateerror(Obj.p, Obj.t);
    
    prRgt0 = 1 - (1 - Obj.t).^Obj.m; % lower bound for Pr{R(p) > 0}

    fdrModified = fdr./prRgt0;
    fdrModified(isnan(fdrModified)) = 0;
    
    assertEqual(pFdr, fdrModified);

    % compare using lambda

    % FDR_lambda1
    lambda1FdrEstimator = org.mensxmachina.stats.mt.error.fdr.lambda.storey2002.storey2002fdrestimator(Obj.m, Obj.lambda);
    lambdaFdr = lambda1FdrEstimator.estimateerror(Obj.p, Obj.t);

    % pFDR_lambda1
    lambda1PFdrEstimator = storey2002pfdrestimator(Obj.m, Obj.lambda);
    lambdaPFdr = lambda1PFdrEstimator.estimateerror(Obj.p, Obj.t);

    lambdaFdrModified = lambdaFdr./prRgt0;
    lambdaFdrModified(isnan(lambdaFdrModified)) = 0;
    
    assertEqual(lambdaPFdr, lambdaFdrModified);

end

function testcmpwithmafdr(Obj)
    
    clc;

    import org.mensxmachina.stats.mt.*;
    import org.mensxmachina.stats.mt.error.fdr.lambda.storey2002.*;

    lambda = 0.5;

    load prostatecancerexpdata;

    p = mattest(dependentData, independentData);
    m = length(p);

    % MA
    
    % FDR_lambda
    maFdr = mafdr(p, 'bhFdr', true);

    % pFDR_lambda
    maLambdaPFdr = mafdr(p, 'lambda', lambda);

    % MxM

    % FDR_lambda
    fdrEstimator = storey2002fdrestimator(m);
    fdr = fdrEstimator.estimateerror(p, p);

    % pFDR_lambda
    lambdaPFdrEstimator = storey2002pfdrestimator(m, lambda);
    lambdaPFdr = lambdaPFdrEstimator.estimateerror(p, p);

    [p_sorted pOrder] = sort(p);
    close all;

    % should be the same expect close to 0
    figure;
    plot(p_sorted, [maFdr(pOrder) fdr(pOrder)]);
    legend({'MA FDR','MxM FDR'});

    % should be the same expect close to 0
    figure;
    plot(p_sorted, [maLambdaPFdr(pOrder) lambdaPFdr(pOrder)]);
    legend({'MA pFDR_{\lambda}', 'MxM pFDR_{\lambda}'});

end

end

end