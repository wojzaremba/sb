function parms = posteriorMeanParamsSlow(dag, nodeArity, data, clamped)

parms = cell(1,length(dag));

if nargin<4, clamped=zeros(size(data)); end

for ni=1:length(dag)
	pa = find( dag(:, ni) )';

	[sfam ord] = sort([pa ni]); % carry-over from posteriorMeanParams by way of AD Tree
	[dum revOrd] = sort(ord);

	sfamsz = nodeArity(sfam);
    
    counts = compute_counts(data(sfam, clamped(ni,:)==0 ), sfamsz); 

	psz = prod(nodeArity(pa));
	if length(sfamsz)==1
		prior = repmat( 1/(psz*nodeArity(ni)), [sfamsz 1] );
	else
		prior = repmat( 1/(psz*nodeArity(ni)), sfamsz );
	end

	if length(revOrd)>1
		parms{ni} = permute(counts + prior, revOrd);
	else
		parms{ni} = counts + prior;
	end

	parms{ni} = mk_stochastic(parms{ni});
end
