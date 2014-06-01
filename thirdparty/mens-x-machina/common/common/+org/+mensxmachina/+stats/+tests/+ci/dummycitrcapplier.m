classdef(Sealed) dummycitrcapplier < org.mensxmachina.stats.tests.ci.citrcapplier
%DUMMYCITRCAPPLIER Dummy-conditional-independence-test-reliability-criterion applier.
%   ORG.MENSXMACHINA.STATS.TESTS.CI.DUMMYCITRCAPPLIER is the class of
%   dummy-conditional-independence-test-reliability-criterion appliers. The
%   dummy conditional-independence-test reliability criterion considers all
%   tests reliable.

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

properties(SetAccess = immutable)
    
nVars % number of variables -- a numeric nonnegative integer
    
end

methods

% constructor

function Obj = dummycitrcapplier(nVars)
%DUMMYCITRCAPPLIER Create dummy-conditional-independence-test-reliability-criterion applier.
%   OBJ = ORG.MENSXMACHINA.STATS.TESTS.CI.DUMMYCITRCAPPLIER(M) creates a
%   dummy-conditional-independence-test-reliability-criterion applier with
%   M variables. M is a numeric nonnegative integer.

    % parse input 
    validateattributes(nVars, {'numeric'}, {'scalar', 'nonnegative', 'integer'});
    
    % set properties
    Obj.nVars = nVars;

end

% abstract method implementations

function tf = isreliablecit(~, ~, ~, ~)
    
    % (no validation)
    
    tf = true;
    
end

function wmk = worstmaxcondsetcard(Obj, i, j, k)
    
    % (no validation)
    
    wmk = maxcondsetcard(Obj, i, j, k);
    
end

function bmk = bestmaxcondsetcard(Obj, i, j, k)
    
    % (no validation)
    
    bmk = maxcondsetcard(Obj, i, j, k);
    
end

end

methods(Access = private)

function maxcondsetcard = maxcondsetcard(Obj, i, j, k)
    
    maxcondsetcard = length(k) - (2 - length(i) - length(j));
    
end    
    
end

end