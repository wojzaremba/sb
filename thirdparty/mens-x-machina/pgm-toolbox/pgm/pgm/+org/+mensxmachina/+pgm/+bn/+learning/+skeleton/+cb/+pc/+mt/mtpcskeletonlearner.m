classdef(Sealed) mtpcskeletonlearner < ...
        org.mensxmachina.pgm.bn.learning.skeleton.cb.pc.generalizedpcskeletonlearner
%MTPCSKELETONLEARNER Multiple-testing PC skeleton learner.
%   ORG.MENSXMACHINA.PGM.BN.LEARNING.SKELETON.CB.PC.MT.MTPCSKELETONLEARNER
%   is the class of multiple-testing PC skeleton learners. Multiple-testing
%   PC skeleton learners consider a d-separation by performing a hypothesis
%   test of conditional independence, updating the corresponding
%   link-absence-test p-value accordingly and then applying a multiple
%   testing procedure to the link-absence-test p-values.
%
%   ORG.MENSXMACHINA.PGM.BN.LEARNING.SKELETON.CB.PC.MT.MTPCSKELETONLEARNER/LEARNSKELETON
%   triggers a citPerformed event with
%   conditional-independence-test-performed data when a test is performed.
%
%   After the learner has run, link-absence-test p-values are stored in
%   property pValues. Property pValues is an M-by-M numeric matrix. Values
%   in the lower triangle of the matrix are the link-absence p-values of
%   the corresponding links. The rest values of the matrix are 0. The
%   statistics corresponding to the link-absence-test p-values in property
%   pValues are stored in property stats in the same way.
%
%
%   See also
%   ORG.MENSXMACHINA.PGM.BN.LEARNING.SKELETON.CB.PC.GENERALIZEDPCSKELETONLEARNER,
%   ORG.MENSXMACHINA.PGM.BN.LEARNING.SKELETON.SKELETONLEARNER,
%   ORG.MENSXMACHINA.STATS.TESTS.CI.CITPVALUEESTIMATOR,
%   ORG.MENSXMACHINA.STATS.TESTS.CI.CITRCAPPLIER,
%   ORG.MENSXMACHINA.STATS.MT.MTP.MTPAPPLIER.

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
    
CITRCApplier % conditional-independence-test-reliability-criterion applier
CITPValueEstimator % conditional-independence-test-p-value estimator
   
MtpApplier % multiple-testing-procedure applier
    
end

properties(SetAccess = private)
    
pValues % p-values -- an M-by-M numeric matrix
stats % statistics -- an M-by-M numeric matrix
    
end

events
    
citPerformed % conditional-independence test performed
    
end

methods

% protected constructor

function Obj = mtpcskeletonlearner(CITRCApplier, CITPValueEstimator, MtpApplier, varargin) 
%MTPCSKELETONLEARNER Create multiple-testing PC skeleton learner.
%   SL = ORG.MENSXMACHINA.STATS.TESTS.CI.CITDSEPDETERMINER(RCAPP, PEST,
%   MTPAPP) creates a multiple-testing PC skeleton learner with
%	reliability-criterion applier RCAPP with M variables, p-value estimator
%   PEST with M variables, multiple-testing-procedure applier MTPAPP with
%	M*(M - 1)/2 hypotheses and maximal sepset cardinality M - 2.
%
%   D = ORG.MENSXMACHINA.STATS.TESTS.CI.CITDSEPDETERMINER(RCAPP, PEST,
%   MTPAPP, C) creates a learner with maximal sepset cardinality C. C is a
%   numeric integer in range [0 (M - 2)].
    
    % parse input
    
    validateattributes(CITRCApplier, {'org.mensxmachina.stats.tests.ci.citrcapplier'}, {'scalar'});
    
    nVars = CITRCApplier.nVars;
    
    validateattributes(CITPValueEstimator, {'org.mensxmachina.stats.tests.ci.citpvalueestimator'}, {'scalar'});
    assert(CITPValueEstimator.nVars == nVars);
    
    validateattributes(MtpApplier, {'org.mensxmachina.stats.mt.mtp.mtpapplier'}, {'scalar'});
    assert(MtpApplier.nHypotheses == nVars*(nVars - 1)/2);
    
    
    % call GENERALIZEDPCSKELETONLEARNER constructor
    Obj = Obj@org.mensxmachina.pgm.bn.learning.skeleton.cb.pc.generalizedpcskeletonlearner(nVars, varargin{:});
    
    
    % set properties
    Obj.CITRCApplier = CITRCApplier;
    Obj.CITPValueEstimator = CITPValueEstimator;
    Obj.MtpApplier = MtpApplier;
    Obj.pValues = zeros(Obj.nVars, Obj.nVars);
    Obj.stats = zeros(Obj.nVars, Obj.nVars);
    
end

end

methods(Access = protected)
    
% abstract method implementations

function skeleton = updateskeleton(Obj, skeleton, i, j, k)
    
    import org.mensxmachina.stats.tests.utils.comparepvalues;
    import org.mensxmachina.pgm.bn.learning.cb.cit.citperformeddata;

    if isreliablecit(Obj.CITRCApplier, i, j, k) % test is reliable, attempt it

        % calculate test p-value
        [p stat] = citpvalue(Obj.CITPValueEstimator, i, j, k);

        if j > i
            sub1 = j;
            sub2 = i;
        else
            sub1 = i;
            sub2 = j;
        end

        if comparepvalues(p, stat, Obj.pValues(sub1, sub2), Obj.stats(sub1, sub2)) > 0

            % update link max CI p-value
            Obj.pValues(sub1, sub2) = p;

            % update link max CI p-value statistic
            Obj.stats(sub1, sub2) = stat;

            % apply MTP
            skeleton = applymtp(Obj, skeleton);

        end

    else
        
        p = NaN;
        stat = NaN;

    end
    
    notify(Obj, 'citPerformed', citperformeddata(i, j, k, p, stat));

end

function msc = maxsepsetcard(Obj, i, j, ind)

    % return CI test RC's best-case maximal conditioning set cardinality
    msc = bestmaxcondsetcard(Obj.CITRCApplier, i, j, ind);
    
end

end

methods(Access = private)   

function skeleton = applymtp(Obj, skeleton)

    % Apply p-value procedure

    % get p-value cutoff threshold
    pThreshold = Obj.MtpApplier.mtpthreshold(full(Obj.pValues(find(skeleton))));
    
    discardInd = find(skeleton & Obj.pValues > pThreshold);

    if ~isempty(discardInd) % there exist links to discard

        % discard them
        skeleton(discardInd) = 0;

%         if Param.Verbose
%             fprintf('\nPairs discarded from skeleton:\n');
%             [discardSub1 discardSub2] = ind2sub(size(skeleton), discardInd);
%             for l=1:length(discardSub1)
%                 fprintf('%d-%d', discardSub1(l), discardSub2(l));
%                 if l < length(discardSub1)
%                     fprintf(', ');
%                 end
%                 fprintf('\n');
%             end
%         end

    end   

end

end

end