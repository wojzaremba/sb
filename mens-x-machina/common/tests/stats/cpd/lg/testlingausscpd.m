classdef testlingausscpd < TestCase

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

    cpd
    
    n
    dy

end

methods

function Obj = testlingausscpd(name)

    clc;
    
    import org.mensxmachina.stats.cpd.cpdvartype;
    import org.mensxmachina.stats.cpd.lg.lingausscpd;

    Obj = Obj@TestCase(name);
    
    e = cpdvartype.Explanatory;
    r = cpdvartype.Response;

    varNames = {'var1', 'var2', 'var3', 'var4', 'var5'};
    varTypes = [e e r r r];
    b = [1 2 3; 4 5 6];
    mu = [0 0 0];
    sigma = ones(1, 3);

    Obj.cpd = lingausscpd(varNames, varTypes, b, mu, sigma);

    Obj.n = 10;
    Obj.dy = normrnd(0, 1, Obj.n, 2);
    Obj.dy = dataset(Obj.dy(:, 1), Obj.dy(:, 2), 'VarNames', {'var1', 'var2'});

end

function testb(Obj)

    clc;

    % test non-numeric
    assertExceptionThrown(@setnonnumeric, 'MATLAB:invalidType');
    function setnonnumeric()
        org.mensxmachina.stats.cpd.lg.lingausscpd(Obj.cpd.varNames, Obj.cpd.varTypes, logical(Obj.cpd.b), Obj.cpd.mu, Obj.cpd.sigma);
    end

    % test non-real
    assertExceptionThrown(@setnonreal, 'MATLAB:expectedReal');
    function setnonreal()
        org.mensxmachina.stats.cpd.lg.lingausscpd(Obj.cpd.varNames, Obj.cpd.varTypes, complex(Obj.cpd.b, zeros(size(Obj.cpd.b))), Obj.cpd.mu, Obj.cpd.sigma);
    end

    % test NaN
    assertExceptionThrown(@setnan, 'MATLAB:expectedNonNaN');
    function setnan()
        b = Obj.cpd.b;
        b(1) = NaN;
        org.mensxmachina.stats.cpd.lg.lingausscpd(Obj.cpd.varNames, Obj.cpd.varTypes, b, Obj.cpd.mu, Obj.cpd.sigma);
    end

    % test bad size
    assertExceptionThrown(@setbadsize, 'MATLAB:incorrectSize');
    function setbadsize()
        org.mensxmachina.stats.cpd.lg.lingausscpd(Obj.cpd.varNames, Obj.cpd.varTypes, reshape(Obj.cpd.b, [1 size(Obj.cpd.b)]), Obj.cpd.mu, Obj.cpd.sigma);
    end

end

function testmu(Obj)

    clc;

    % test non-numeric
    assertExceptionThrown(@setnonnumeric, 'MATLAB:invalidType');
    function setnonnumeric()
        org.mensxmachina.stats.cpd.lg.lingausscpd(Obj.cpd.varNames, Obj.cpd.varTypes, Obj.cpd.b, logical(Obj.cpd.mu), Obj.cpd.sigma);
    end

    % test non-real
    assertExceptionThrown(@setnonreal, 'MATLAB:expectedReal');
    function setnonreal()
        org.mensxmachina.stats.cpd.lg.lingausscpd(Obj.cpd.varNames, Obj.cpd.varTypes, Obj.cpd.b, complex(Obj.cpd.mu, zeros(size(Obj.cpd.mu))), Obj.cpd.sigma);
    end

    % test NaN
    assertExceptionThrown(@setnan, 'MATLAB:expectedNonNaN');
    function setnan()
        mu = Obj.cpd.mu;
        mu(1) = NaN;
        org.mensxmachina.stats.cpd.lg.lingausscpd(Obj.cpd.varNames, Obj.cpd.varTypes, Obj.cpd.b,mu, Obj.cpd.sigma);
    end

    % test bad size
    assertExceptionThrown(@setbadsize, 'MATLAB:incorrectSize');
    function setbadsize()
        org.mensxmachina.stats.cpd.lg.lingausscpd(Obj.cpd.varNames, Obj.cpd.varTypes, Obj.cpd.b, Obj.cpd.mu(1), Obj.cpd.sigma);
    end

end

function testsigma(Obj)

    clc;

    % test bad
    assertExceptionThrown(@setbad, 'stats:mvnpdf:BadMatrixSigma'); % R2011b
    %assertExceptionThrown(@setBad, 'stats:mvnrnd:BadCovariance'); % R2009b
    
    function setbad()
        sigma = [1 2 2; 2 1 2; 2 2 1];
        org.mensxmachina.stats.cpd.lg.lingausscpd(Obj.cpd.varNames, Obj.cpd.varTypes, Obj.cpd.b, Obj.cpd.mu, sigma);
    end

end

% function testparserandominput(Obj)
%     
%     clc;
% 
%     % test non-dataset
%     assertExceptionThrown(@setnondataset, 'MATLAB:assert:failed');
%     function setnondataset()
%         Obj.cpd.arevalidexplanatoryvariablevalues('char');
%     end
% 
%     % test bad size dataset 
%     assertExceptionThrown(@setbadsizedataset, 'MATLAB:assert:failed');
%     function setbadsizedataset()
%         Obj.cpd.arevalidexplanatoryvariablevalues(Obj.dy(:, 1));
%     end
% 
%     % test missing variable dataset
%     assertExceptionThrown(@setmissingvariabledataset, 'MATLAB:assert:failed');
%     function setmissingvariabledataset()
%         dy = Obj.dy;
%         dy.Properties.VarNames{1} = 'bad';
%         Obj.cpd.arevalidexplanatoryvariablevalues(dy);
%     end
%     
%     tf = Obj.cpd.arevalidexplanatoryvariablevalues(Obj.dy);
%     assertTrue(tf);
%     
%     dy = Obj.dy;
%     dy.Var1 = complex(dy.Var1, zeros(size(dy.Var1)));
%     tf = Obj.cpd.arevalidexplanatoryvariablevalues(dy);
%     assertFalse(tf);
%     
% end

function testrandom(Obj)
    
    import org.mensxmachina.stats.cpd.cpdvartype;

    reset(RandStream.getDefaultStream);
    x = Obj.cpd.random(Obj.dy);
    assertEqual(x.Properties.VarNames, Obj.cpd.varNames(Obj.cpd.varTypes == cpdvartype.Response));
   
end

function testsubsref(Obj)
    
    clc;
    
    % ()
    
    assertExceptionThrown(@testbadlength, 'MATLAB:assert:failed');
    function testbadlength()
        Obj.cpd(1, 2, 3)
    end
    
    assertExceptionThrown(@testnonscalar, 'MATLAB:assert:failed');
    function testnonscalar()
        Obj.cpd(1, 2, 1:2)
    end
    
    assertExceptionThrown(@testcolon, 'MATLAB:assert:failed');
    function testcolon()
        Obj.cpd(1, 2, :)
    end
    
    Obj.cpd(1, 2, 3, 4, 5)
    
    % .
    
    assertEqual(length(Obj.cpd.varNames), 5);

    % {}
    
    assertExceptionThrown(@usecellsubs, 'MATLAB:cellRefFromNonCell');
    function usecellsubs()
        Obj.cpd{1, 2, 3, 4, 5}
    end
    
end

function testpermute(Obj)
    
    order = randperm(length(Obj.cpd.varNames))
    
    Obj.cpd
    
    cpd = permute(Obj.cpd, order);
    
    cpd
    
    cpd = ipermute(cpd, order);
    
    assertEqual(cpd, Obj.cpd);
    
end

function testdisplay(Obj)

    clc;

    Obj.cpd
    
end

end

end