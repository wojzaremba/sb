function Gs = mkAllDagsSlow(N, order)
% MK_ALL_DAGS generate all DAGs on N variables
% G = mk_all_dags(N)
%
% G = mk_all_dags(N, order) only generates DAGs in which node i has parents from
% nodes in order(1:i-1). Default: order=[] (no constraints).
%
% G{i} is the i'th dag
%
% Note: the number of DAGs is super-exponential in N, so don't call this with N > 5.

if nargin < 2, order = []; end

use_file = true;

fname = sprintf('Cache/DAGS%d_slow.mat', N);
if use_file & exist(fname, 'file')
	S = load(fname, '-mat');
	fprintf('loading %s\n', fname);
	Gs = S.Gs;
	return;
end

m = 2^(N*N);
Gs = {};
j = 1;
directed = 1;
for i=1:m
	ind = ind2subv(2*ones(1,N^2), i);
	dag = reshape(ind-1, N, N);
	if acyclic(dag, directed)
		out_of_order = 0;
		if ~isempty(order)
			for k=1:N-1
				if any(dag(order(k+1:end), k))
					out_of_order = 1;
					break;
				end
			end
		end
		if ~out_of_order
			Gs{j} = dag;
			j = j + 1;
		end
	end
	if mod(i, 5000)==0
		fprintf('%i/%i %i\n', i, m, j);
	end
end

if use_file
	disp(['mk_all_dags: saving to ' fname '!']);
	save(fname, 'Gs');
end