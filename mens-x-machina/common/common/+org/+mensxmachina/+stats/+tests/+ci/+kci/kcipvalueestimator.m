classdef(Sealed) kcipvalueestimator < org.mensxmachina.stats.tests.ci.citpvalueestimator
%KCIPVALUEESTIMATOR kernel-conditional-independence-p-value estimator.
%   ORG.MENSXMACHINA.STATS.TESTS.CI.KCI.KCIPVALUEESTIMATOR is
%   the class of kernel-test-of-conditional-independence-p-value
%   estimators.

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
%
% This file added by Rachel Hodos (hodos@cims.nyu.edu) on 5/27/2014.

properties(SetAccess = immutable)
    
nVars % number of variables -- a numeric nonnegative integer
    
end

properties(GetAccess = private, SetAccess = immutable)
    
sample % sample -- an M-by-N numeric matrix of positive integers

end

methods
    
function Obj = kcipvalueestimator(sample)
%KCIPVALUEESTIMATOR Create kernel-conditional-independence-p-value estimator.
%   OBJ =
%   ORG.MENSXMACHINA.STATS.TESTS.CI.KCI.KCIPVALUEESTIMATOR(SAMPLE)
%   creates a kernel-conditional-independence-p-value estimator
%   with sample SAMPLE. SAMPLE is an M-by-N numeric real matrix, where M is
%   the number of observations and N is the number of variables in the
%   sample. Each element of SAMPLE is the value of the corresponding
%   variable for the corresponding observation.
    
    % parse input
    validateattributes(sample, {'numeric'}, {'2d', 'real'});
    
    % set properties
    Obj.nVars = size(sample, 2);
    Obj.sample = sample;
    
end
    
end

methods

% abstract method implementations

function [p, stat] = citpvalue(Obj, i, j, k)
    
    % params (abstract this elsewhere in a common place accessible to
    % this and my code!)
    lambda = 1E-3;
    eig_frac = 1/4;
    Thresh = 1E-5;
    G = GaussKernel();
    
    % (no validation)
    ind = [i j k];    
    assert(length(ind) > 1);

    % select test variables
    varSample = Obj.sample(:, ind);
    
    % varSample size
    T = size(varSample, 1);
    
    % conditioning set size
    ns = size(varSample, 2) - 2;
    
    x = varSample(:, 1);
    y = varSample(:, 2);
    H =  eye(T) - ones(T, T) / T;
    Ky = H * G.k(y, y) * H;
    
    if ns > 0
        z = varSample(:, 3:end);
        Kx = H * G.k([x z/2], [x z/2]) * H;
        Kz = H * G.k(z, z) * H;
        P = (eye(T) - Kz*pdinv(Kz + lambda*eye(T)));
        Kx = P * Kx * P';
        Ky = P * Ky * P';
    else
        Kx = H * G.k(x, x) * H;
    end
    
    stat_unnorm = abs(sum(Kx(:) .* Ky(:)));
    num_eig = floor(T*eig_frac);
    
    % calculate the eigenvalues
    %if isempty(prealloc)
    [eig_Kx, eivx] = eigdec((Kx + Kx') / 2, num_eig);
    [eig_Ky, eivy] = eigdec((Ky + Ky') / 2, num_eig);
    %end
    
    % calculate the product of the square root of the eigvectors
    IIx = find(eig_Kx > max(eig_Kx) * Thresh);
    IIy = find(eig_Ky > max(eig_Ky) * Thresh);
    eig_Kx = eig_Kx(IIx);
    eivx = eivx(:,IIx);
    eig_Ky = eig_Ky(IIy);
    eivy = eivy(:,IIy);
    
    eiv_prodx = eivx * diag(sqrt(eig_Kx));
    eiv_prody = eivy * diag(sqrt(eig_Ky));
    clear eivx eig_Kx eivy eig_Ky
    
    % calculate their product
    num_eigx = size(eiv_prodx, 2);
    num_eigy = size(eiv_prody, 2);
    Size_u = num_eigx * num_eigy;
    uu = zeros(T, Size_u);
    
    for i=1:num_eigx
        for j=1:num_eigy
            uu(:,(i-1)*num_eigy + j) = eiv_prodx(:,i) .* eiv_prody(:,j);
        end
    end
    
    if Size_u > T
        uu_prod = uu * uu';
    else
        uu_prod = uu' * uu;
    end
    
    mean_appr = trace(uu_prod);
    var_appr = 2*trace(uu_prod^2);
    k_appr = mean_appr^2/var_appr;
    theta_appr = var_appr/mean_appr;
    p = 1 - gamcdf(stat_unnorm, k_appr, theta_appr);
    stat = sqrt(stat_unnorm / (sum(diag(Kx)) * sum(diag(Ky))));

end

end

end
