classdef potential
%POTENTIAL Potential.
%   ORG.MENSXMACHINA.STATS.CPD.POTENTIAL is the abstract class of
%   potentials. A potential over a set of variables V is a function that
%   maps each instantiation of V into a nonnegative real number. A
%   potential is a likelihood if it maps each instantiation of a single
%   variable into a number <= 1.
%
%   The number of dimensions in a potential is ND = MAX(NV, 2), where NV is
%   the number of variables in that potential. When NV >= 2, the size of
%   each dimension is that of the corresponding variable. The size of a
%   variable is the number of values of that variable and may be Inf. When
%   NV == 1, the size of the second dimension is 1. When NV == 0, both
%   dimensions have size 1.

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

% References:
% [1] Lauritzen, S. L., and Spiegelhalter, D. J., Local computations with
%     probabilities on graphical structures and their application to expert
%     systems, J. Roy. Statist. Soc. Ser B, 50, 157-224, 1988.

properties(Abstract, SetAccess = immutable)
    
varNames % variable names -- a cell array of strings
    
end

methods

function n = ndims(a)
%NDIMS Number of dimensions in a potential.
%   N = NDIMS(P) returns the number of dimensions in potential P. N =
%   LENGTH(SIZE(P)).
%  
%   See also ORG.MENSXMACHINA.STATS.CPD.POTENTIAL/SIZE.

    n = length(size(a));
    
end

end

methods(Abstract)
    
%SUBSREF Subscripted reference for a potential.
%   B = SUBSREF(A, struct('type', '()', 'subs', {VAL1, VAL2, ..., VALN})),
%   where N is the number of variables in potential A, returns the value of
%   A for variable values VAL1, VAL2, ..., VALN.
%
%   B = SUBSREF(A, struct('type', '.', 'subs', {'PropertyName'})), where
%   PropertyName is the name of public property of the class of A, returns
%   the value of that property for A.
%
%   Example:
%
%       % p is a potenrial over variables a and b with values {1; 2} and
%       % {'on'; 'off'} respectivelly
%
%       % get the names of the variables in p
%       p.varNames
%
%       % get the value of p for a = 1 and b = 'off'
%       p(1, 'off')
sref = subsref(Obj, s);

%SIZE Size of a potential.
%   D = size(P) returns the size of potential P. 
%
%   [M1, M2, M3, ..., MN] = size(P) returns the size of each dimension of P
%   as separate output variables.
%
%   M = size(P, DIM) returns the size of dimension DIM.
%  
%   See ORG.MENSXMACHINA.STATS.CPD.POTENTIAL/NDIMS.
varargout = size(x, dim);

% operators

%TIMES Multiply potentials.
%   C = TIMES(A, B) multiplies potentials A and B if their classes are
%   compatible and throws an error otherwise. C is a potential over the
%   union of the variables in A and B. The variables in C are sorted by
%   name.
c = times(a, b);

%RDIVIDE Divide potentials.
%   C = RDIVIDE(A, B) divides potential A with potential B if their classes
%   are compatible and throws an error otherwise. C is a potential over the
%   union of the variables in A and B. The variables in C are sorted by
%   name.
c = rdivide(a, b);

%SUM Marginalize potential.
%   B = SUM(A, I) sums variables I out of potential A. B is a potential
%   over the rest variables in A. I is a numeric row vector containing
%   linear indices of unique variables in A.
m = sum(Obj, i);

% extra

%PERMUTE Permute potential dimensions.
%   B = PERMUTE(A, ORDER) rearranges the dimensions of potential A so that
%   they are in the order specified by ORDER. ORDER is a permutation of
%   1:N, where N is the number of dimensions in A.
%
%   Example:
%
%       % p is a potential over variables a and b
%
%       p.varNames % {'a', 'b'}
%
%       p = permute(p, [2 1]);
% 
%       p.varNames % {'b', 'a'}
%
%   See also PERMUTE, ORG.MENSXMACHINA.STATS.CPD.POTENTIAL/IPERMUTE.
b = permute(a, order);

%IPERMUTE Inverse permute potential dimensions.
%   A = IPERMUTE(B, ORDER) rearranges the dimensions of potential B so that
%   PERMUTE(A, ORDER) will produce B.
%
%   Example:
% 
%       % p is a potential over variables a and b
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
%   See also IPERMUTE, ORG.MENSXMACHINA.STATS.CPD.POTENTIAL/PERMUTE.
b = ipermute(a, order);

% converters

%CPD Convert potential to CPD.
%   CPDOBJ = CPD(POTOBJ) converts potential POTOBJ to a joint probability
%   distribution of the variables in POTOBJ, if possible, and throws an
%   error otherwise.
%
%   CPDOBJ = CPD(POTOBJ, VARTYPES), converts POTOBJ to a conditional
%   probability distribution of the variables in POTOBJ with types
%   VARTYPES, if possible, and throws an error otherwise. VARTYPES is a
%   CPD-variable-type array, where N is the number of variables in POTOBJ.
%   Each element of VARTYPES specifies the type of the corresponding
%   variable (response or explanatory).
%
%   See also ORG.MENSXMACHINA.STATS.CPD.CPD.
cpdObj = cpd(Obj, varTypes);

% state detectors

%ISLIKELIHOOD Determine if potential is likelihood.
%   TF = ISLIKELIHOOD(P) returns logical 1 (true) if potential P is a
%   likelihood and logical 0 (false) otherwise.
tf = islikelihood(Obj);

% utilities

%ONES Create potential of all ones.
%   B = ONES(A) returns a potential B over the variables in potential A
%   such that the value of B is 1 for every instantiation of the variables.
%
%   B = ONES(A, I) creates a potential B over variables I in A. I is a
%   numeric row vector containing linear indices of unique variables in A.
b = ones(Obj, a);

end

methods(Access = protected)
    
% input parsers
    
function parsesuminput(Obj, i)
%PARSESUMINPUT Parse ORG.MENSXMACHINA.STATS.CPD.POTENTIAL/SUM input.
%   PARSESUMINPUT(POTOBJ, ...), when POTOBJ is potential, throws an error
%   if its input is not valid input for
%   ORG.MENSXMACHINA.STATS.CPD.POTENTIAL/SUM.
%
%   See also ORG.MENSXMACHINA.STATS.CPD.POTENTIAL/SUM.
    
    validateattributes(i, {'numeric'}, {'row', 'positive', '<=', length(Obj.varNames)}, 'integer');
    assert(length(unique(i)) == length(i));
    
end
    
function parsesizeinput(Obj, dim)
%PARSESIZEINPUT Parse ORG.MENSXMACHINA.STATS.CPD.POTENTIAL/SIZE input.
%   PARSESIZEINPUT(P, ...), when P is a potential, throws an error if its
%   input is not valid input for ORG.MENSXMACHINA.STATS.CPD.POTENTIAL/SIZE.
%
%   See also ORG.MENSXMACHINA.STATS.CPD.POTENTIAL/SIZE.
    
    if nargin == 1
        validateattributes(dim, {'numeric'}, {'real', 'scalar', 'positive', '<=', ndims(Obj)});
    end
    
end

function varOrder = parsepermuteinput(Obj, order)
%PARSEPERMUTEINPUT Parse ORG.MENSXMACHINA.STATS.CPD.POTENTIAL/PERMUTE or
%ORG.MENSXMACHINA.STATS.CPD.POTENTIAL/IPERMUTE input.
%   VARORDER = PARSEPERMUTEINPUT(P, ...), when P is a potential, throws an
%   error if its input is not valid input for
%   ORG.MENSXMACHINA.STATS.CPD.POTENTIAL/PERMUTE or
%   ORG.MENSXMACHINA.STATS.CPD.POTENTIAL/IPERMUTE. VARORDER is the order of
%   variables corresponding to order ORDER of dimensions.
%
%   See also ORG.MENSXMACHINA.STATS.CPD.POTENTIAL/PERMUTE,
%   ORG.MENSXMACHINA.STATS.CPD.POTENTIAL/IPERMUTE.

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
    
function varTypes = parsecpdinput(Obj, varTypes)
%PARSECPDINPUT Parse ORG.MENSXMACHINA.STATS.CPD.POTENTIAL/CPD input.
%   VARTYPES = PARSECPDINPUT(POTOBJ, ...), when POTOBJ is a potential,
%   throws an error if its input is not valid input for
%   ORG.MENSXMACHINA.STATS.CPD.POTENTIAL/CPD. VARTYPES is an 1-by-N
%   CPD-variable-type array, where N is the number of variables in POTOBJ.
%   Each element of VARTYPES specifies the type of the corresponding
%   variable (response or explanatory) in output CPDOBJ of
%   ORG.MENSXMACHINA.STATS.CPD.POTENTIAL/CPD.
%
%   See also ORG.MENSXMACHINA.STATS.CPD.POTENTIAL/CPD.
    
    import org.mensxmachina.stats.cpd.cpdvartype;
    
    if nargin < 2
        varTypes = repmat(cpdvartype.Response, 1, length(Obj.varNames));
    else
        assert(isa(varTypes, 'org.mensxmachina.stats.cpd.cpdvartype') && isequal(size(varTypes), size(Obj.varNames)));
    end

end

function parseonesinput(Obj, i)
%PARSEONESINPUT Parse ORG.MENSXMACHINA.STATS.CPD.POTENTIAL/ONES input.
%   PARSEONESINPUT(POTOBJ, ...), when POTOBJ is a potential, throws an
%   error if its input is not valid input for
%   ORG.MENSXMACHINA.STATS.CPD.POTENTIAL/ONES.
%
%   See also ORG.MENSXMACHINA.STATS.CPD.POTENTIAL/ONES.
    
    validateattributes(i, {'numeric'}, {'row', 'positive', '<=', length(Obj.varNames)}, 'integer');
    assert(length(unique(i)) == length(i));
    
end
    
end

end