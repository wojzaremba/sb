classdef testby2001fdrestimator < TestCase

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

    byFdrEstimator
    fdrEstimator

    m
    p
    t

end

methods

function Obj = testby2001fdrestimator(name)
    
    import org.mensxmachina.stats.mt.error.fdr.by2001.by2001fdrestimator;
    import org.mensxmachina.stats.mt.error.fdr.lambda.storey2002.storey2002fdrestimator;

    Obj = Obj@TestCase(name);

    Obj.m = 8;

    Obj.p = [0 0.001 0.01 0.01 0.05 0.1 0.5 1]';
    Obj.p = Obj.p(randperm(length(Obj.p)));
    
    Obj.t = [0 0.005 0.03 0.07 0.7 1]';
    tOrder = randperm(length(Obj.t));
    Obj.t = Obj.t(tOrder);
    
    Obj.byFdrEstimator = by2001fdrestimator(Obj.m);
    Obj.fdrEstimator = storey2002fdrestimator(Obj.m);

end

function testcmpwithstorey2001(Obj)

    clc;
    
    byFdr = Obj.byFdrEstimator.estimateerror(Obj.p, Obj.t);
    fdr = Obj.fdrEstimator.estimateerror(Obj.p, Obj.t);

    assertElementsAlmostEqual(byFdr, min(fdr*sum(1./(1:Obj.m)), 1));

end

end

end