classdef cpd
%CPD Conditional probability distribution.
%   ORG.MENSXMACHINA.STATS.CPD.CPD is the abstract class of conditional
%   probability distributions.

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
    
varTypes % variable types -- an 1-by-NV CPD-variable-type array
varNames % variable names -- an 1-by-NV cell array of strings
    
end

methods

function n = ndims(a)
%NDIMS Number of dimensions in a conditional probability distribution.
%   ND = NDIMS(P) returns the number of dimensions in conditional
%   probability distribution P. ND = LENGTH(SIZE(P)).
%  
%   See also ORG.MENSXMACHINA.STATS.CPD.CPD/SIZE.

    n = length(size(a));
    
end

end

methods(Abstract)

%RANDOM Random sample from a conditional probability distribution.
%   XS = RANDOM(P, YS) returns a random sample from conditional probability
%   P given values in sample YS of the explanatory variables in P. YS is a
%   dataset with M observations of the explanatory variables in P (and
%   possibly other variables). XS is a dataset with M observations of the
%   response variables in P.
%
%   Example:
%
%       % p is a conditional probability distribution with explanatory
%       % variables a and b and response variables c and d
%
%       % ys is a dataset comprised of N observations of variables a, b,
%       % and f
%
%       % xs is a dataset comprised of N observations of variables c and d
%       xs = random(p, ys)
%
%   See also DATASET.
xs = random(Obj, ys);

%SUBSREF Subscripted reference for a conditional probability distribution.
%   B = SUBSREF(A, struct('type', '()', 'subs', {VAL1, VAL2, ..., VALN})),
%   where N is the number of variables in conditional probability
%   distribution A, returns the probability of variable values VAL1, VAL2,
%   ..., VALN.
%
%   B = SUBSREF(A, struct('type', '.', 'subs', {'PropertyName'})), where
%   PropertyName is the name of public property of the class of A, returns
%   the value of that property for A.
%
%   Example:
%
%       % p is the conditional probability distribution of variable a with
%       % values {1; 2} given variable b with values {'on'; 'off'}; a comes
%       % first in cpd and b comes second.
%
%       % get P(A = 1|B = 'off')
%       cpd(1, 'off')
sref = subsref(Obj, s);

%SIZE Size of a conditional probability distribution.
%   D = size(P) returns the size of conditional probability distribution P.
%
%   [M1, M2, M3, ..., MN] = size(P) returns the size of each dimension of P
%   as separate output variables.
%
%   M = size(P, DIM) returns the size of dimension DIM.
%  
%   See ORG.MENSXMACHINA.STATS.CPD.CPD/NDIMS.
d = size(x, dim);

%PERMUTE Permute conditional probability distribution dimensions.
%   B = PERMUTE(A, ORDER) rearranges the dimensions of conditional
%   probability distribution A so that they are in the order specified by
%   ORDER. ORDER is a permutation of 1:N, where N is the number of
%   dimensions in A.
%
%   Example:
%
%       % p is a conditional probability distribution with variables a and
%       % b
%
%       p.varNames % {'a', 'b'}
%
%       p = permute(p, [2 1]);
% 
%       p.varNames % {'b', 'a'}
%
%   See also PERMUTE, ORG.MENSXMACHINA.STATS.CPD.CPD/IPERMUTE.
b = permute(a, order);

%IPERMUTE Inverse permute potential dimensions.
%   A = IPERMUTE(B, ORDER) rearranges the dimensions of conditional
%   probability distribution B so that PERMUTE(A, ORDER) will produce B.
%
%   Example:
% 
%       % p is a conditional probability distribution with variables a and
%       % b
%
%       p.varNames % {'a', 'b'}
%
%       p = permute(p, [2 1]);
% 
%       p.varNames % {'b', 'a'}
% 
%       p = ipermute(p, [2 1]);
% 
%       p.varNames % {'a', 'b'}
%
%   See also IPERMUTE, ORG.MENSXMACHINA.STATS.CPD.CPD/PERMUTE.
b = ipermute(a, order);

end

methods(Access = protected)

% input parsers
    
function parsesizeinput(Obj, dim)
%PARSESIZEINPUT Parse ORG.MENSXMACHINA.STATS.CPD.CPD/SIZE input.
%   PARSESIZEINPUT(P, ...), when P is a conditional probability
%   distribution, throws an error if its input is not valid input for
%   ORG.MENSXMACHINA.STATS.CPD.CPD/SIZE.
%
%   See also ORG.MENSXMACHINA.STATS.CPD.CPD/SIZE.
    
    if nargin == 1
        validateattributes(dim, {'numeric'}, {'real', 'scalar', 'positive', '<=', ndims(Obj)});
    end
    
end

function varOrder = parsepermuteinput(Obj, order)
%PARSEPERMUTEINPUT Parse ORG.MENSXMACHINA.STATS.CPD.CPD/PERMUTE or ORG.MENSXMACHINA.STATS.CPD.CPD/IPERMUTE input.
%   VARORDER = PARSEPERMUTEINPUT(P, ...), when P is conditional probability
%   distribution, throws an error if its input is not valid input for
%   ORG.MENSXMACHINA.STATS.CPD.CPD/PERMUTE or
%   ORG.MENSXMACHINA.STATS.CPD.CPD/IPERMUTE. VARORDER is the order of
%   variables corresponding to order ORDER of dimensions.
%
%   See also ORG.MENSXMACHINA.STATS.CPD.CPD/PERMUTE,
%   ORG.MENSXMACHINA.STATS.CPD.CPD/IPERMUTE.

    import org.mensxmachina.array.isorder;
    
    assert(isorder(order));
    
    switch length(Obj.varNames)
        case 0
            varOrder = zeros(1, 0);
        case 1
            varOrder = 1;
        otherwise
            varOrder = order;
    end

end

end

end