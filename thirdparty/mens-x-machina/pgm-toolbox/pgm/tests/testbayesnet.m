classdef testbayesnet < TestCase
%TESTBAYESNET BayesianNetwork class test cases

properties
    
    bayesNet
    
end

methods

function Obj = testbayesnet(name)
    
    import org.mensxmachina.pgm.bn.tabular.sprinkler;
    
    clc;

    Obj = Obj@TestCase(name);

    % create the sprinkler example network
    Obj.bayesNet = sprinkler;

end

function testskeleton(Obj)
    
    clc;

    trueskeleton = sparse(4, 4);

    trueskeleton(2,1) = 1;
    trueskeleton(3,1) = 1;
    trueskeleton(4,2) = 1;
    trueskeleton(4,3) = 1;

    assertTrue(isequal(skeleton(Obj.bayesNet), trueskeleton));

end

function testsubsref(Obj)
    
    clc;
    
    levels = nominal([1; 2], {'false', 'true'}, [1 2]);
    
    assertEqual(Obj.bayesNet(levels(1), levels(1), levels(1), levels(1)), 0.5*0.5*0.8*1);
    assertEqual(Obj.bayesNet(levels(2), levels(1), levels(2), levels(1)), 0.5*0.9*0.8*0.1);
    assertEqual(length(Obj.bayesNet.varNames), 4);

    % use {}
    assertExceptionThrown(@usecellsubs, 'MATLAB:numel:BadSubscriptingIndex');
    function usecellsubs()
        Obj.bayesNet{levels(1), levels(1), levels(1), levels(1)}
    end
    
end

function testsize(Obj)
    
    clc;
    
    assertEqual(size(Obj.bayesNet), [2 2 2 2]);
    assertEqual(size(Obj.bayesNet, 1), 2);
    assertEqual(size(Obj.bayesNet, 2), 2);
    assertEqual(size(Obj.bayesNet, 3), 2);
    assertEqual(size(Obj.bayesNet, 4), 2);
    
end

function testpermute(Obj)
    
    order = randperm(length(Obj.bayesNet.varNames));
    
    %Obj.bayesNet
    
    cpd = permute(Obj.bayesNet, order);
    
    order
    cpd
    
    cpd = ipermute(cpd, order);
    
    order
    cpd
    
    assertEqual(cpd, Obj.bayesNet);
    
end

function testrandom(Obj)
    
    clc;
    
    % depends on bayesnet mat files
    
    bNetNames = {'alarm', 'andes', 'barley', 'diabetes', 'hailfinder', 'heparii', 'link', 'munin', 'pathfinder', 'win95pts', 'insurance', 'mildew', 'pigs', 'water', 'powerplant'};

    bNetNames = bNetNames(1);
    
    for i = 1:length(bNetNames)
        
        load(sprintf('%s_bayesnet_sample', bNetNames{i}), 'Sample'); % load sample
        load(sprintf('%s_bayesnet', bNetNames{i}), 'BayesNet'); % load BayesNet

        % reset default random number stream
        stream = RandStream('mrg32k3a');

        % set default stream to 1st substream
        set(stream,'Substream', i);
        RandStream.setDefaultStream(stream);

        Sample1 = random(BayesNet, dataset.empty(10000, 0));
        
        assertEqual(Sample, Sample1);
        
    end

end

function testdisplay(Obj)
    
    clc;

    Obj.bayesNet
    
end

end

end