classdef citrcminnobsbounder < handle
%CITRCMINNOBSBOUNDER Conditional-independence-test-reliability-criterion minimal-sample-size bounder.
%   ORG.MENSXMACHINA.STATS.TESTS.CI.CITRCMINNOBSBOUNDER is the abstract
%   class of conditional-independence-test-reliability-criterion
%   minimal-sample-size bounders. A
%   conditional-independence-test-reliability-criterion minimal-sample-size
%   bounder bounds, for a set of variables, the minimal sample size for
%   which hypothesis tests of conditional independence involving variables
%   of the set and having conditioning-set cardinality up to some maximum
%   cardinality are reliable according to a reliability critetion.

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

properties(Abstract, SetAccess = immutable)
    
nVars % number of variables -- a numeric nonnegative integer
    
end

methods(Abstract)

%WORSTMINNOBS Upper-bound worst-case minimal sample size.
%   UB = WORSTMINNOBS(NOBSBOBJ, I, J, IND, K), where NOBSBOBJ is a
%   conditional-independence-test-reliability-criterion minimal-sample-size
%   bounder, I and J is the linear index of CITRCAPPLIER variable X and Y,
%   respectivelly, and IND are the linear indices of set S of CITRCAPPLIER
%   variables, and K is a conditioning-set cardinality, returns an upper
%   bound on XY worst-case minimal sample size (XY-worst-min-n) of S. The
%   XY-worst-min-n of S is the minimal sample size such that all tests of
%   conditional independence of X and Y given a subset of S with
%   cardinality <= K are reliable according to the reliability criterion of
%   NOBSBOBJ. I and J are numeric integers in range [1, M], where M is the
%   number of CITRCAPPOBJ variables. IND is a numeric row vector of
%   integers in range [1, M]. K is a numeric integer in range [0,
%   LENGTH(IND)]. UB is a numeric positive integer.
%
%   UB = WORSTMINNOBS(NOBSBOBJ, I, ZEROS(1, 0), IND, K) returns an upper
%   bound on X worst-case minimal sample size (X-worst-min-n) of S. The X
%   worst-min-n of S is the minimal sample size such that all tests of
%   conditional independence of X with any variable Y of S given a subset
%   of S\{Y} with cardinality <= K are reliable according to the
%   reliability criterion of NOBSBOBJ. K is in range [0, LENGTH(IND) - 1].
%
%   UB = WORSTMINNOBS(NOBSBOBJ, ZEROS(1, 0), I, IND, K) is the same as UB =
%   WORSTMINNOBS(NOBSBOBJ, I, ZEROS(1, 0), IND, K).
%
%   UB = WORSTMINNOBS(NOBSBOBJ, ZEROS(1, 0), ZEROS(1, 0), IND, K) returns
%   an upper bound on worst-case minimal sample size (worst-min-n) of S.
%   The worst-min-n of S is the minimal sample size such that all tests of
%   conditional independence of variables X and Y of S given a subset of
%   S\{X, Y} with cardinality <= K are reliable according to the
%   reliability criterion of NOBSBOBJ. K is in range [0, LENGTH(IND) - 2].
ub = worstminnobs(Obj, i, j, ind, k);

%BESTMINNOBS Lower-bound best-case minimal sample size.
%   LB = BESTMINNOBS(NOBSBOBJ, I, J, IND, K), where NOBSBOBJ is a
%   conditional-independence-test-reliability-criterion minimal-sample-size
%   bounder, I and J is the linear index of CITRCAPPLIER variable X and Y,
%   respectivelly, and IND are the linear indices of set S of CITRCAPPLIER
%   variables, and K is a conditioning-set cardinality, returns a lower
%   bound on XY best-case minimal sample size (XY-best-min-n) of S. The
%   XY-best-min-n of S is the minimal sample size such that at least one
%   test of conditional independence of X and Y given a subset of S with
%   cardinality <= K is reliable according to the reliability criterion of
%   NOBSBOBJ. LB is a numeric positive integer.
%
%   LB = BESTMINNOBS(NOBSBOBJ, I, ZEROS(1, 0), IND, K) returns a lower
%   bound on X best-case minimal sample size (X-best-min-n) of S. The
%   X-best-min-n of S is the minimal sample size such that at least one
%   test of conditional independence of X with any variable Y of S given a
%   subset of S\{Y} with cardinality <= K is reliable according to the
%   reliability criterion of NOBSBOBJ.
%
%   LB = BESTMINNOBS(NOBSBOBJ, ZEROS(1, 0), I, IND, K) is the same as LB =
%   BESTMINNOBS(NOBSBOBJ, I, ZEROS(1, 0), IND, K).
%
%   LB = BESTMINNOBS(NOBSBOBJ, ZEROS(1, 0), ZEROS(1, 0), IND, K) returns a
%   lower bound on best-case minimal sample size (best-min-n) of S. The
%   best-min-n of S is the minimal sample size such that at least one test
%   of conditional independence of variables X and Y of S given a subset of
%   S\{X, Y} with cardinality <= K is reliable according to the reliability
%   criterion of NOBSBOBJ.
lb = bestminnobs(Obj, i, j, ind, k);

end

methods(Access = protected)

function parseminnobsinput(Obj, i, j, ind, k)
%PARSEMINNOBSINPUT Parse ORG.MENSXMACHINA.STATS.TESTS.CI.CITRCMINNOBSBOUNDER/WORSTMINNOBS or ORG.MENSXMACHINA.STATS.TESTS.CI.CITRCMINNOBSBOUNDER/BESTMINNOBS input.
%   PARSEMINNOBSINPUT(NOBSBOBJ, ...), when NOBSBOBJ is
%   conditional-independence-test-reliability-criterion minimal-sample-size
%   bounder, throws an error if its input is not valid input for
%   ORG.MENSXMACHINA.STATS.TESTS.CI.CITRCMINNOBSBOUNDER/WORSTMINNOBS or
%   ORG.MENSXMACHINA.STATS.TESTS.CI.CITRCMINNOBSBOUNDER/BESTMINNOBS.
%
%   See also
%   ORG.MENSXMACHINA.STATS.TESTS.CI.CITRCMINNOBSBOUNDER/WORSTMINNOBS,
%   ORG.MENSXMACHINA.STATS.TESTS.CI.CITRCMINNOBSBOUNDER/BESTMINNOBS.
    
    validateattributes(i, {'numeric'}, {'row', 'positive', '<=', Obj.nVars, 'integer'});
    assert(length(i) < 1);
    
    validateattributes(j, {'numeric'}, {'row', 'positive', '<=', Obj.nVars, 'integer'});
    assert(length(j) < 1);
    
    validateattributes(ind, {'numeric'}, {'row', 'positive', '<=', Obj.nVars, 'integer'});
   
    validateattributes(k, {'numeric'}, {'integer', 'scalar', 'nonnegative', '<=', length(i) + length(j) + length(ind) - 2});

end

end

end