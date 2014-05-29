classdef generalizedpcskeletonlearner < ...
        org.mensxmachina.pgm.bn.learning.skeleton.skeletonlearner
%GENERALIZEDPCSKELETONLEARNER Generalized PC skeleton learner.
%   ORG.MENSXMACHINA.PGM.BN.LEARNING.SKELETON.CB.PC.GENERALIZEDPCSKELETONLEARNER
%   is the abstract class of generalized PC skeleton learners. In contrast
%   to PC, which discards a link if a d-separation is found, an instance of
%   generalized PC may discard a set of links after a d-separation is
%   considered.
%
%   See also ORG.MENSXMACHINA.PGM.BN.LEARNING.SKELETON.SKELETONLEARNER.

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
% [3] Y. Li and Z. Y. Wang. Controlling the false discovery rate of the
%     association/causality structure learned with the pc algorithm. Y.
%     Mach. Learn. Res., 10:475-514, 2009. ISSN 1532-4435.

properties(SetAccess = immutable)
    
nVars % number of variables -- a numeric nonnegative integer
    
maxSepsetCard % maximal sepset-cardinality -- a numeric nonnegative integer
    
end

methods

% protected constructor

function Obj = generalizedpcskeletonlearner(nVars, maxSepsetCard)
%GENERALIZEDPCSKELETONLEARNER Create generalized PC skeleton learner.
%   L =
%   ORG.MENSXMACHINA.PGM.BN.LEARNING.SKELETON.CB.PC.GENERALIZEDPCSKELETONLEARNER(M)
%   creates a generalized PC skeleton learner with M variables and maximal
%   sepset cardinality M - 2. M is a numeric nonnegative integer.
%
%   L =
%   ORG.MENSXMACHINA.PGM.BN.LEARNING.SKELETON.CB.PC.GENERALIZEDPCSKELETONLEARNER(M,
%   C) creates a learner with maximal sepset cardinality C. C is a numeric
%   integer in range [0 (M - 2)].
    
    validateattributes(nVars, {'numeric'}, {'scalar', 'nonnegative', 'integer'});
    
    if nargin < 2
        maxSepsetCard = nVars - 2;
    else
        validateattributes(maxSepsetCard, {'numeric'}, {'scalar', 'nonnegative', '<=', nVars - 2, 'integer'});
    end
    
    % set properties
    Obj.nVars = nVars;
    Obj.maxSepsetCard = maxSepsetCard;
    
end

end

methods

% abstract method implementations

function skeleton = learnskeleton(Obj)

    import org.mensxmachina.pgm.bn.learning.skeleton.cb.pc.generalizedpcskeletonlearner;

    % initialize skeleton
    skeleton = sparse(Obj.nVars, Obj.nVars);
    skeleton(find(tril(ones(Obj.nVars, Obj.nVars), -1))) = 1;
    
    % upper-bound sepset cardinality
    msc = maxsepsetcard(Obj, zeros(1, 0), zeros(1, 0), 1:Obj.nVars);
    
    if isnan(msc) % no d-separations
        return;
    end

    % limit sepset cardinality
    msc = min(msc, Obj.maxSepsetCard);
    
    iRepeat = 0;

    while true

        fprintf('\nk = %d\n', iRepeat);

        for i = 1 : Obj.nVars % for each variable

            for j = find(skeleton(i, :) | skeleton(:, i)') % for each variable Y in TPC(X)

                % get TPC(X)\{Y}
                xTpcIndMinusJ = setdiff(find(skeleton(i, :) | skeleton(:, i)'), j);
                
                % upper-bound XY sepset cardinality
                ijMsc = maxsepsetcard(Obj, i, j, xTpcIndMinusJ);
                
                if isnan(ijMsc) || ijMsc < iRepeat
                    
                    % either no d-separations or maximal sepset cardinality
                    % is < the currently checked sepset cardinality
                    continue;
                    
                end
                
                % find subsets of TPC(X)\{Y} with cardinality iRepeat

                if isempty(xTpcIndMinusJ)

                    if iRepeat == 0
                        subsets = zeros(1, 0);
                    else
                        subsets = [];
                    end

                elseif length(xTpcIndMinusJ) == 1

                    if iRepeat == 0
                        subsets = zeros(1, 0);
                    elseif iRepeat == 1
                        subsets = xTpcIndMinusJ;
                    else
                        subsets = [];
                    end

                else
                    subsets = nchoosek(xTpcIndMinusJ, iRepeat);
                end

                for iSubset = 1:size(subsets, 1) % for each such subset

                    % let it be Z
                    k = subsets(iSubset, :);

                    % update skeleton after considering Ind(X;Y|Z)
                    skeleton = updateskeleton(Obj, skeleton, i, j, k);

                    if ~skeleton(max(i, j), min(i, j))
                        break;
                    end

                end

            end

        end
        
        iRepeat = iRepeat + 1;

        if max(sum(skeleton | skeleton')) <= iRepeat || iRepeat > msc
            break;
        end

    end
    
end

end

methods(Abstract, Access = protected)
    
% Note: Help for the following methods will be added in the future.

%UPDATESKELETON Update skeleton after considering d-separation.
skeleton = updateskeleton(Obj, skeleton, i, j, k);

%MAXSEPSETCARD Upper-bound sepset cardinality.
msc = maxsepsetcard(Obj, i, j, ind);

end

end