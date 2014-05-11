function equivDags = findMarkovEquivDags(dag)
% given a seed dag, find all the elements of its markov equivalence class

cpdag = dag_to_cpdag(dag);
cpdagp = dag_to_essential_graph(dag); % convenient representation

[r c] = find((triu(cpdag)+tril(cpdag)')==2); % get the undirected edges

equivDags = {};

sm = zeros(size(dag));
N = 1;

for gi=0:2^length(r)-1
	bits = bitget(gi,1:length(r));
	
	mdag = double( cpdagp==2 );
	for bi=1:length(bits)
		if bits(bi)
			mdag(r(bi),c(bi)) = 1;
		else
			mdag(c(bi),r(bi)) = 1;
		end
	end

	if ~acyclic(mdag), continue; end
	
	cpmdag = dag_to_cpdag(mdag);
	if any(cpmdag(:) ~= cpdag(:))
		continue;
	end
	
	equivDags{N} = mdag;

	sm = sm + mdag;
	N = N + 1;

end
