function Gs = all_dags(N, n_parents)
tic;
choices = {[]};
for k = 1:n_parents
    choices = [choices; num2cell(nchoosek(1:N, k), 2)];
end
m = length(choices) ^ N;
Gs = {};
k = 1;
directed = 1;
fprintf('Iterating over %d elements\n', m);
for i=1:m
    dag = zeros(N, N);
    for j =1:N
        % XXX: Check if dimension should be fliped.
        dag(choices{mod(floor((i - 1) / (N ^ (j - 1))), N) + 1}, j) = 1;    
    end
    if acyclic(dag, directed)   
        Gs{k} = dag;
        k = k + 1;    
    end
end
fprintf('Generation took %f sec.\n', toc);