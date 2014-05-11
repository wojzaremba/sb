function L  = logMargLikMultiFamily( pa, ni, nodeArity, alpha, intervention, unclampedADTreePtr, clampedADTreePtr )
% Computes L = log p(x(child) | x(parents))
%
% data(all cases, all nodes)
% intervention.clampedMask(m, ni) if node ni is clamped in case m
% nodeArity(ni) = num states for node ni
% alpha = Dirichlet hyper param

global priorCache;

% changed it to sorted since mkContab EXPECTS a sorted list
[sfam ordAll] = sort([pa ni]); 
ord = find(sfam==ni); % the dimension we'll sum over later

sfamsz = nodeArity(sfam);

%counts2 = compute_counts(unclampedData([pa ni], : ), nodeArity([pa ni]));  % too slow, using AD Trees now
counts = mkContab( unclampedADTreePtr, sfam, sfamsz );

% full-time BDeu prior now
% this should be a @param
if ~isempty(priorCache)
	prior = priorCache{length(sfam)};
else
	psz = prod(nodeArity(pa));
	% prior = (alpha/psz) * mk_stochastic(myones(famsz)); too slow (slower
	% by a factor of 2 than what follows)
	
	if length(sfamsz)==1
		prior = repmat( alpha/(psz*sfamsz(ord)), [sfamsz 1] ); % assumes that last dimensions are not degenerate (ie. not 1)
	else
		prior = repmat( alpha/(psz*sfamsz(ord)), sfamsz ); % assumes that last dimensions are not degenerate (ie. not 1)
	end
end

L = dirichlet_score_family(counts, prior, length(sfam), ord);

if ~strcmp(intervention.type, 'perfect')

	
	switch intervention.type
		case 'imperfect'  % Tian & Pearl 01
			% now assume same hyperparameters on "changed" distribution as on
			% non-intervened one
            clampedCounts = mkContab( clampedADTreePtr, sfam, sfamsz );
			L = L + dirichlet_score_family(clampedCounts, prior, length(sfam), ord);

		case 'soft' % Markowetz et al. 2005
								
            % get rid of all the unclamped cases, remember softTarget is
            % the same size as clamped to begin with (it should be 0
            % wherever clamped is 0, and 1..K wherever clamped is 1 (1..K
            % denoting the arity)            
            
            for ti=1:length(intervention.softUniqueTargets)
                target = intervention.softUniqueTargets(ti); 

                % modify the prior with a "push" on the target value
                % multiply the spike strength by the no. of cases to put its
                % "power" on the same order as the counts

                clampedCounts = mkContab( clampedADTreePtr(ti), sfam, sfamsz );
			                
                pasz = prod(nodeArity(pa));
                inds = [1 2:pasz] + pasz*(target-1);
                
                pushedPrior = prior;
                N = sum(clampedCounts(:));
                pushedPrior( inds ) = pushedPrior( inds ) + intervention.softPushStrength*N;
                if length(pa)>0
                    pushedPrior = permute(pushedPrior, ordAll);
                end
                
                L = L + dirichlet_score_family(clampedCounts, pushedPrior, length(sfam), ord, true);
            end
            
		otherwise
			error('unhandled intervention type: %s', intervention.type);
	end
end

function LL = dirichlet_score_family( counts, prior, nvar, ord, noCachePrior )
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

global gammalnPriorCache;

if isempty(gammalnPriorCache) || nargin>4 % in the case we're using soft interventions, cannot use gammaln(prior) cache
	LU = sum(gammaln(prior + counts) - gammaln(prior), ord);
else
	LU = sum(gammaln(prior + counts) - gammalnPriorCache{1,nvar}, ord);
end

alpha_ij = sum(prior, ord); alpha_ij = alpha_ij(:); % sum over k
N_ij = sum(counts, ord); N_ij = N_ij(:);
if isempty(gammalnPriorCache) || nargin>4
	LV = gammaln(alpha_ij) - gammaln(alpha_ij + N_ij);
else
	LV = gammalnPriorCache{2,nvar}(:) - gammaln(alpha_ij + N_ij);
end

LL = sum(LU(:) + LV);


