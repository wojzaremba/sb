classdef testroc < TestCase
%TESTROC ROC test cases

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

    targets
    outputs
    
    realizedTpr
    realizedFpr
    thresholds

end

methods

function Obj = testroc(name)

    clc;
    
    import org.mensxmachina.classification.performance.roc;

    Obj = Obj@TestCase(name);

    Obj.targets = logical([0 1 0 0 1 1 0 0]);
    Obj.outputs = [-1 2 1 -4 5 -1 4 -4];
    
    Obj.realizedTpr = [  0 1/3 1/3 2/3 2/3   1  1];
    Obj.realizedFpr = [  0   0 1/5 1/5 2/5 3/5  1];
    Obj.thresholds  = [Inf   5   4   2   1  -1 -4];

end


function testdefault(Obj)

    clc;
    
    import org.mensxmachina.classification.performance.roc;
    
    [realizedTpr realizedFpr threshold] = roc(Obj.targets, Obj.outputs);
    
    assertEqual(realizedTpr, Obj.realizedTpr);
    assertEqual(realizedFpr, Obj.realizedFpr);
    assertEqual(threshold, Obj.thresholds);
    
end

function testtarget(Obj)

    clc;
    
    import org.mensxmachina.classification.performance.roc;

    % test non-logical
    assertExceptionThrown(@setnonlogical, 'MATLAB:invalidType');
    function setnonlogical()
        import org.mensxmachina.classification.performance.roc;
        roc(double(Obj.targets), Obj.outputs);
    end

    % test non-vector
    assertExceptionThrown(@setnonvector, 'MATLAB:expectedVector');
    function setnonvector()
        import org.mensxmachina.classification.performance.roc;
        roc(reshape(Obj.targets, 1, 1, []), Obj.outputs);
    end

    % test sparse
    roc(sparse(Obj.targets), Obj.outputs);

end

function testoutput(Obj)

    clc;

    % test non-numeric
    assertExceptionThrown(@setnonnumeric, 'MATLAB:invalidType');
    function setnonnumeric()
        import org.mensxmachina.classification.performance.roc;
        roc(Obj.targets, logical(Obj.outputs));
    end

    % test non-real
    assertExceptionThrown(@setnonreal, 'MATLAB:expectedReal');
    function setnonreal()
        import org.mensxmachina.classification.performance.roc;
        roc(Obj.targets, complex(Obj.outputs, zeros(size(Obj.outputs))));
    end

    % test non-vector
    assertExceptionThrown(@setnonvector, 'MATLAB:expectedVector');
    function setnonvector()
        import org.mensxmachina.classification.performance.roc;
        roc(Obj.targets, reshape(Obj.outputs, 1, 1, []));
    end

    % test NaN
    assertExceptionThrown(@setnan, 'MATLAB:expectedNonNaN');
    function setnan()
        import org.mensxmachina.classification.performance.roc;
        roc(Obj.targets, [Obj.outputs NaN]);
    end

    % test bad length
    assertExceptionThrown(@setbadlength, 'MATLAB:assert:failed');
    function setbadlength()
        import org.mensxmachina.classification.performance.roc;
        roc(Obj.targets, Obj.outputs(1:end-1));
    end
    
    % test sparse
    roc(Obj.targets, sparse(Obj.outputs));

end

function testcmpwithbuiltinroc(Obj)
    
    % Note: this test requires MATLAB(R) Neural Network Toolbox(TM).

    load iris_dataset;

    net = newpr(irisInputs,irisTargets,20);
    net = train(net,irisInputs,irisTargets);
    irisOutputs = sim(net,irisInputs); 

    [nnRealizedTpr nnRealizedFpr nnThresholds] = roc(irisTargets,irisOutputs);

    for i = 1:3

        [tpr fpr threshold] = org.mensxmachina.classification.performance.roc(logical(irisTargets(i, :)), irisOutputs(i, :));

        assertElementsAlmostEqual(nnRealizedTpr{i}(2:end), tpr);
        assertElementsAlmostEqual(nnRealizedFpr{i}(2:end), fpr);
        assertElementsAlmostEqual(nnThresholds{i}(2:end-1), threshold(2:end)); 

    end

end

end

end