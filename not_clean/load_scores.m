fid = fopen('LL.names', 'r');
tline = fgets(fid);
names = {};
while ischar(tline)
    names{end+1} = strtrim(tline);
    tline = fgets(fid); 
end
fclose(fid);

E = {};
N = [];
for i = 1:length(names)
   Ename = ['E' names{i}(3:end)];
   A = load(Ename);
   if size(A, 1) == 20
       E{end+1} = A;
       s = strsplit(names{i}, '_');
       N(end+1) = str2num(s{2});
   end
end

[N, order] = sort(N);
E = E(order);
T = get_dag(struct('network', 'child', 'moralize', false));
K = triu(ones(size(T)), 1);
edge = find(T);
non_edge = intersect(find(K), find(~T));
n = length(edge);
m = length(non_edge);

figure
hold on
ns  = unique(N);

for i = 1:length(E)
    sub = find(ns == N(i));
    subplot(1, 4, sub)
    hold on
    e = E{i};
    h(1) = scatter(rand(n, 1), e(edge), 'b.');
    h(2) = scatter(rand(m, 1), e(non_edge), 'r.');
    %ylim([0 800]);
    title(sprintf('N = %d', 100*sub));
end

legend(h, 'edge', 'no edge');


