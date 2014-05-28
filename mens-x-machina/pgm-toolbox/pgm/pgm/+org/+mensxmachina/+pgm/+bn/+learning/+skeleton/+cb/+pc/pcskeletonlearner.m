classdef(Sealed) pcskeletonlearner < ...
        org.mensxmachina.pgm.bn.learning.skeleton.cb.pc.generalizedpcskeletonlearner
%PCSKELETONLEARNER PC skeleton learner.
%   ORG.MENSXMACHINA.PGM.BN.LEARNING.SKELETON.CB.PC.PCSKELETONLEARNER is
%   the class of PC skeleton learners.
%
%   After the learner has run, sepsets are stored in property sepsets.
%   Property sepsets is an M-by-M cell array, where M is the number of
%   variable of the learner. Each value in the lower triangle of property
%   sepsets that is not [] is a numeric row vector of positive integers
%   that are the linear indices of the variables of the corresponding
%   sepset. Rest values in property sepsets are [].
%
%   See also
%   ORG.MENSXMACHINA.PGM.BN.LEARNING.SKELETON.CB.PC.GENERALIZEDPCSKELETONLEARNER,
%   ORG.MENSXMACHINA.PGM.BN.LEARNING.SKELETON.SKELETONLEARNER,
%   ORG.MENSXMACHINA.PGM.BN.LEARNING.CB.DSEPDETERMINER.

% Copyright 2010-2012 Mens X Machina
% 
% This file is part of Mens X Machina Probabilistic Graphical Model
% Toolbox.
% 
% Mens X Machina Probabilistic Graphical Model Toolbox is free software:
% you can redistribute it and/or modify it under the terms of the GNU
% General Public License alished by the Free Software Foundation, either
% version 3 of the License, or (at your option) any later version.
% 
% Mens X Machina Probabilistic Graphical Model Toolbox is distributed in
% the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
% the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
% PURPOSE. See the GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License along
% with Mens X Machina Probabilistic Graphical Model Toolbox. If not, see
% <http://www.gnu.org/licenses/>.

% References:
% [1] P. Spirtes, C.N. Glymour, and R. Scheines. Causation, prediction, and
%     search. 2000. ISBN 0262194406.
% [2] R.E. Neapolitan. Learning bayesian networks. Pearson Prentice Hall
%     Upper Saddle River, NJ, 2004. ISBN 0130125342.

properties(SetAccess = immutable)
    
DSepDeterminer % d-separation determiner
    
end

properties(SetAccess = private)
    
sepsets % sepsets -- an M-by-M cell array
    
end

methods

% protected constructor

function Obj = pcskeletonlearner(DSepDeterminer, varargin)
%PCSKELETONLEARNER Create PC skeleton learner.
%   L = ORG.MENSXMACHINA.PGM.BN.LEARNING.SKELETON.CB.PC.PCSKELETONLEARNER(D)
%   creates a PC skeleton learner with d-separation determiner D and
%   maximal sepset cardinality M - 2, where M is the number of variables of
%   D.
%
%   L = ORG.MENSXMACHINA.PGM.BN.LEARNING.SKELETON.CB.PC.PCSKELETONLEARNER(D,
%   C) creates a PC skeleton learner with maximal sepset cardinality C. C
%   is a numeric integer in range [0 (M - 2)].
%
%   See also ORG.MENSXMACHINA.PGM.BN.LEARNING.CB.DSEPDETERMINER.

    % parse input
    validateattributes(DSepDeterminer, {'org.mensxmachina.pgm.bn.learning.cb.dsepdeterminer'}, {'scalar'});
    
    % call GENERALIZEDPCSKELETONLEARNER constructor
    Obj = Obj@org.mensxmachina.pgm.bn.learning.skeleton.cb.pc.generalizedpcskeletonlearner(DSepDeterminer.nVars, varargin{:});
    
    % set properties
    Obj.DSepDeterminer = DSepDeterminer;
    Obj.sepsets = cell(Obj.nVars, Obj.nVars); 
    
end

end

methods(Access = protected)
    
% abstract method implementations

function skeleton = updateskeleton(Obj, skeleton, i, j, k)
    
    if isdsep(Obj.DSepDeterminer, i, j, k)

        if j > i
            sub1 = j;
            sub2 = i;
        else
            sub1 = i;
            sub2 = j;
        end
        
        % discard link
        skeleton(sub1, sub2) = false;
        
        % set sepset
        Obj.sepsets{sub1, sub2} = k;
        
    end

end

function msc = maxsepsetcard(Obj, i, j, ind)

    msc = maxsepsetcard(Obj.DSepDeterminer, i, j, ind);
    
end

end

end