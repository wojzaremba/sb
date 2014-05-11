function parms = posteriorMeanParams(dag, nodeArity, ADTreePtr)

parms = cell(1,length(dag));

if size(nodeArity,1)>size(nodeArity,2), nodeArity = nodeArity'; end

for ni=1:length(dag)
	pa = find( dag(:, ni) )';

	[sfam ord] = sort([pa ni]);
	[dum revOrd] = sort(ord);

	sfamsz = nodeArity(sfam);

	counts = mkContab( ADTreePtr, sfam, sfamsz );

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
