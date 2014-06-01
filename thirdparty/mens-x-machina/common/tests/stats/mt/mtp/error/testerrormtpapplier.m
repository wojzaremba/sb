classdef testerrormtpapplier < TestCase

properties
    
    m
    p
    fdr
    
    pPermInd2PInd
    
    pPerm
    fdrPerm
    
    fdrThreshold
    pThreshold
    ind
    
    indPPerm
    
    fdrEstimator
    fdrControlProcApplier
    
end

methods

function Obj = testerrormtpapplier(name)
    
    import org.mensxmachina.stats.mt.error.fdr.lambda.storey2002.storey2002fdrestimator;
    import org.mensxmachina.stats.mt.mtp.error.errormtpapplier;

    Obj = Obj@TestCase(name);

    Obj.p = [0.0001, 0.0004, 0.0019, 0.0095, 0.0201, 0.0278, 0.0298, ...
        0.0344, 0.0459, 0.324,  0.4262, 0.5719, 0.6528, 0.759, 1.000]';
    
    Obj.m = length(Obj.p);
    
    Obj.fdrEstimator = storey2002fdrestimator(Obj.m);
    
    Obj.fdr = estimateerror(Obj.fdrEstimator, Obj.p, Obj.p);
    
    Obj.pPermInd2PInd = randperm(length(Obj.p));
    
    Obj.pPerm = Obj.p(Obj.pPermInd2PInd);
    Obj.fdrPerm = Obj.fdr(Obj.pPermInd2PInd);
    
    Obj.fdrThreshold = 0.05;
    
    Obj.pThreshold = 0.0095;
    
    Obj.fdrControlProcApplier = errormtpapplier(Obj.fdrEstimator, Obj.fdrThreshold);
    
end

function testdefault(Obj)
  
    clc;

    pThreshold = Obj.fdrControlProcApplier.mtpthreshold(Obj.p);
    assertEqual(pThreshold, Obj.pThreshold);

    pThreshold = Obj.fdrControlProcApplier.mtpthreshold(Obj.pPerm);
    assertEqual(pThreshold, Obj.pThreshold);
    
end

end

end