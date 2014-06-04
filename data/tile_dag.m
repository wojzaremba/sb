function tdag = tile_dag(dag, k)
% make k disconnected copies of dag structure, represent as single dag

nvars = size(dag, 1);
tdag = zeros(k * nvars);

for i = 1:k
   idx = (1:nvars) + nvars * (i - 1);
   tdag(idx, idx) = dag; 
end
