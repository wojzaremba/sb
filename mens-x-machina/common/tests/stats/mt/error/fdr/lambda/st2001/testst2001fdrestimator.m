classdef testst2001fdrestimator < TestCase

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
    
    st2001FdrEstimator
    
    p
    t

end

methods

function Obj = testst2001fdrestimator(name)
    
    clc;

    import org.mensxmachina.stats.mt.error.fdr.lambda.st2001.st2001fdrestimator;

    Obj = Obj@TestCase(name);

    Obj.p = [0 0.001 0.01 0.01 0.05 0.1 0.5 1]';
    Obj.p = Obj.p(randperm(length(Obj.p)));
    
    Obj.t = [0 0.005 0.03 0.07 0.7 1]';
    tOrder = randperm(length(Obj.t));
    Obj.t = Obj.t(tOrder);
    
    Obj.st2001FdrEstimator = st2001fdrestimator(length(Obj.p), ones(1, 8)*7, repmat({ones(5, 1)}, 1, 8));

end

function testm0(Obj)

    clc;

    assertExceptionThrown(@setnonnumeric, 'MATLAB:invalidType');
    function setnonnumeric()
        org.mensxmachina.stats.mt.error.fdr.lambda.st2001.st2001fdrestimator(Obj.st2001FdrEstimator.nHypotheses, 'aa', {ones(1, 8), ones(1, 8)});
    end

    assertExceptionThrown(@setnonreal, 'MATLAB:expectedNonnegative');
    function setnonreal()
        org.mensxmachina.stats.mt.error.fdr.lambda.st2001.st2001fdrestimator(Obj.st2001FdrEstimator.nHypotheses, repmat(1i, 1, 2), {ones(1, 8), ones(1, 8)});
    end

end

function testp0(Obj)

    clc;

    assertExceptionThrown(@setnoncellp0, 'MATLAB:invalidType');
    function setnoncellp0()
        org.mensxmachina.stats.mt.error.fdr.lambda.st2001.st2001fdrestimator(Obj.st2001FdrEstimator.nHypotheses, Obj.st2001FdrEstimator.nNullPValues, []);
    end

    assertExceptionThrown(@setbadsize, 'MATLAB:incorrectSize');
    function setbadsize()
        org.mensxmachina.stats.mt.error.fdr.lambda.st2001.st2001fdrestimator(Obj.st2001FdrEstimator.nHypotheses, ones(1, 4), {ones(1, 8), ones(1, 8)});
    end

    assertExceptionThrown(@setnonnumericp0element, 'MATLAB:assert:failed');
    function setnonnumericp0element()
        p0 = Obj.st2001FdrEstimator.nullPValues;
        p0{end} = 'bad';
        org.mensxmachina.stats.mt.error.fdr.lambda.st2001.st2001fdrestimator(Obj.st2001FdrEstimator.nHypotheses, Obj.st2001FdrEstimator.nNullPValues, p0);
    end

    assertExceptionThrown(@setnonrealip0, 'MATLAB:assert:failed');
    function setnonrealip0()
        p0 = Obj.st2001FdrEstimator.nullPValues;
        p0{end} = complex(p0{end}, zeros(size(p0{end})));
        org.mensxmachina.stats.mt.error.fdr.lambda.st2001.st2001fdrestimator(Obj.st2001FdrEstimator.nHypotheses, Obj.st2001FdrEstimator.nNullPValues, p0);
    end

end

function testwithrealdata(Obj)

    clc;

    import org.mensxmachina.stats.mt.*;

    % configuration
    
    lambda = 0.5;

    load prostatecancerexpdata;

    p = mattest(dependentData, independentData);
    m = length(p);

    % simulation

    b = 2; % # of simulations

    allData = [dependentData independentData];

    p0 = cell(1, b);
    m0 = size(allData, 1)*ones(1, b);

    for i = 1 : b % for each simulation

        fprintf('\nRunning permutation #%d...\n', i);

        perm = randperm(size(allData, 2));

        allData_perm = allData(:, perm);

        p0{i} = mattest(allData_perm(:, 1:size(dependentData, 2)), allData_perm(:, (size(dependentData, 2) + 1):end));

    end

    % LAMBDA = 0
    st2001FdrEstimator = org.mensxmachina.stats.mt.error.fdr.lambda.st2001.st2001fdrestimator(m, m0, p0);
    fdr = st2001FdrEstimator.estimateerror(p, p);

    % LAMBDA
    st2001LambdaFdrEstimator = org.mensxmachina.stats.mt.error.fdr.lambda.st2001.st2001fdrestimator(m, m0, p0, lambda);
    fdrWithLambda = st2001LambdaFdrEstimator.estimateerror(p, p);

    % plot

    close all;

    [p_sorted p_order] = sort(p);

    figure;
    plot(p_sorted, [fdrWithLambda(p_order) fdr(p_order)]);
    legend({'MxM st2001FdrEstimator-FDR_{\lambda}', 'MxM st2001FdrEstimator-FDR_0'});
    ylim([0 1]);

end

end

end