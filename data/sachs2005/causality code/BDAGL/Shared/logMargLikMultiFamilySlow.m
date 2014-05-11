function L  = logMargLikMultiFamily( unclampedData, clampedData, pa, ni, nodeArity, alpha, intervention )
% Computes L = log p(x(child) | x(parents))
%
% data(all cases, all nodes)
% intervention.clampedMask(m, ni) if node ni is clamped in case m
% nodeArity(ni) = num states for node ni
% alpha = Dirichlet hyper param

fam = [pa ni];
famsz = nodeArity(fam);
counts = compute_counts(unclampedData(fam, : ), famsz);

% full-time BDeu prior now
% this should be a @param
% prior = alpha*myones(famsz);
psz = prod(nodeArity(pa));
prior = (alpha/psz) * mk_stochastic(myones(famsz));

L = dirichlet_score_family(counts, prior);

if isempty( findstr(intervention.type, 'perfect') ) % not perfect or uncertainPerfect

	clampedCounts = compute_counts(clampedData(fam,:), famsz);
	
	switch intervention.type
		case 'imperfect'  % Tian & Pearl 01
			% now assume same hyperparameters on "changed" distribution as on
			% non-intervened one
			L = L + dirichlet_score_family(clampedCounts, prior);

		case 'soft' % Markowetz et al. 2005
			
			% ****** assume that we only clamp to one value!!! otherwise we
			% have to for loop over the different intervention targets
			
			% modify the prior with a "push" on the target value
			% multiply the spike strength by the no. of cases to put its
			% "power" on the same order as the counts
			softTarget = intervention.softTarget(ni,:);
			softTarget = softTarget( softTarget>0 );
			
			if numel(softTarget)>0
				softTarget = softTarget(1);
				
				pasz = prod(nodeArity(pa));
				inds = [1 2:pasz] + pasz*(softTarget-1);
				prior( inds ) = prior( inds ) + intervention.softPushStrength*size(clampedData,2);

				L = L + dirichlet_score_family(clampedCounts, prior);
			end
			
		otherwise
			error('unhandled intervention type: %s', intervention.type);
	end
end

%%%%%%%%%

function LL = dirichlet_score_family(counts, prior)
% DIRICHLET_SCORE Compute the log marginal likelihood of a single family
% LL = dirichlet_score(counts, prior)
%
% counts(a, b, ..., z) is the number of times parent 1 = a, parent 2 = b, ..., child = z
% prior is an optional multidimensional array of the same shape as counts.
% It defaults to a uniform prior.
%
% We marginalize out the parameters:
% LL = log \int \prod_m P(x(ni,m) | x(Pa_i,m), theta_i) P(theta_i) d(theta_i)


% LL = log[  prod_j gamma(alpha_ij)/gamma(alpha_ij + N_ij)  *
%            prod_k gamma(alpha_ijk + N_ijk)/gamma(alpha_ijk)  ]
% Call the prod_k term U and the prod_j term  V.
% We reshape all quantities into (j,k) matrices
% This formula was first derived by Cooper and Herskovits, 1992.
% See also "Learning Bayesian Networks", Heckerman, Geiger and Chickering, MLJ 95.

ns = mysize(counts);
ns_ps = ns(1:end-1);
ns_self = ns(end);

if nargin < 2, prior = normalise(myones(ns)); end

prior = reshape(prior(:), [prod(ns_ps) ns_self]);
counts = reshape(counts,  [prod(ns_ps) ns_self]);
%U = prod(gamma(prior + counts) ./ gamma(prior), 2); % mult over k
LU = sum(gammaln(prior + counts) - gammaln(prior), 2);
alpha_ij = sum(prior, 2); % sum over k
N_ij = sum(counts, 2);
%V = gamma(alpha_ij) ./ gamma(alpha_ij + N_ij);
LV = gammaln(alpha_ij) - gammaln(alpha_ij + N_ij);
%L = prod(U .* V);
LL = sum(LU + LV);


