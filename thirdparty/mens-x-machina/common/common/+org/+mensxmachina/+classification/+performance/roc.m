function [realizedTpr realizedFpr threshold] = roc(targets, outputs)
%ROC Receiver Operating Characteristic (ROC) curve points.
%   [REALIZEDTPR REALIZEDFPR THRESHOLDS] =
%   ORG.MENSXMACHINA.CLASSIFICATION.PERFORMANCE.ROC(TARGETS, OUTPUTS)
%   calculates the realized False Positive Rate (FPR) REALIZEDTPR and False
%   Negative Rate (FNR) REALIZEDFPR corresponding to each threshold
%   THRESHOLDS on a scoring classifier's outputs OUTPUTS, given the
%   classifier's targets TARGETS. TARGETS is a logical row vector. OUTPUTS
%   is a numeric real row vector of the same length as TARGETS and without
%   NaNs. Each pair of values (REALIZEDTPR(k), REALIZEDFPR(k)) defines a
%   point on the Receiver Operating Characteristic (ROC) curve.
%
%   Example:
%
%       targets = logical([0 1 0 0 1 1 0 0]);
%       outputs = [-1 2 1 -4 5 -1 4 -4];
%    
%       [realizedTpr realizedFpr threshold] = roc(targets, outputs);
%
%   See also ROC.

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
% [1] T. Fawcett. ROC graphs: Notes and practical considerations for data
%     mining researchers, 2003.

validateattributes(targets, {'logical'}, {'vector'});
validateattributes(outputs, {'numeric'}, {'real', 'vector', 'nonnan'});
assert(length(outputs) == length(targets));

numP = sum(targets); % # of positives
numN = length(targets) - numP; % # of negatives

% sort outputs and targets by score
[outputs sortInd] = sort(outputs, 'descend');
targets = targets(sortInd);

numFP = 0;
numTP = 0;
f_prev = Inf;

realizedFpr = [];
realizedTpr = [];
threshold = [];

for i=1:length(targets) % for each example
    
    if outputs(i) ~= f_prev
            
        realizedFpr = [realizedFpr numFP/numN];
        realizedTpr = [realizedTpr numTP/numP];
        threshold = [threshold f_prev];
        
        f_prev = outputs(i);
        
    end
    
    if targets(i) % i is a positive example
        numTP = numTP + 1;
    else % i is a negative example
        numFP = numFP + 1;
    end
    
end

% this is (1,1)

realizedFpr = [realizedFpr numFP/numN];
realizedTpr = [realizedTpr numTP/numP];
threshold = [threshold f_prev];

end