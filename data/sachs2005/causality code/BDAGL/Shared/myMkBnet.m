function bnet = myMkBnet(N, arity, varargin)
% N - number of nodes
% arity - singleton or vector
% optional/varargin parameters:
% paramMethod - 'dirichlet' or 'meek'
% 'dirichlet' 'alpha' p controls amt of entropy in bn
% 'meek' use method of meek & chickering with corresp ESS

[method, dag, ESS, alpha, bnet] = process_options(varargin, 'method', 'dirichlet', ...
	'dag', mk_rnd_dag(N), ...
	'ESS', 10, ...
	'alpha', 0.5, 'bnet', [] );

if isempty(bnet)
    if(length(arity)==1), arity = repmat(arity,[1 N]); end

    bnet = mk_bnet(dag, arity);
end

for i=1:N
	ps = bnet.parents{i};
	switch method
		case 'dirichlet'
			CPT = dirichlet_sample(alpha*ones(1,arity(i)), prod(arity(ps)) );
		case 'meek'
			mu = 1./(1:arity(i)); mu = mu/sum(mu) * ESS;
			CPT = zeros(prod(arity(ps)), arity(i));
			for j=1:size(CPT,1)
				mu = mu( [length(mu) 1:(length(mu)-1)] );
				CPT(j, :) = dirichlet_sample(mu, 1);
			end
		case 'boldmeek'
			mu = 1./((1:arity(i)).^2); mu = mu/sum(mu) * ESS * 1.5;
			CPT = zeros(prod(arity(ps)), arity(i));
			for j=1:size(CPT,1)
				mu = mu( [length(mu) 1:(length(mu)-1)] );
				CPT(j, :) = dirichlet_sample(mu, 1);
            end		
		case 'ultraboldmeek'
			mu = 1./((1:arity(i)).^2); mu = mu/sum(mu) * ESS * 4;
			CPT = zeros(prod(arity(ps)), arity(i));
			for j=1:size(CPT,1)
				mu = mu( [length(mu) 1:(length(mu)-1)] );
				CPT(j, :) = dirichlet_sample(mu, 1);
            end		    
        case 'smalldir'
            if isempty(ps)
                alpha = 1;
            else                
                alpha = 0.1;
            end
            CPT = dirichlet_sample(alpha*ones(1,arity(i)), prod(arity(ps)) );	
	end
	bnet.CPD{i} = tabular_CPD(bnet, i, 'CPT', CPT);
end

