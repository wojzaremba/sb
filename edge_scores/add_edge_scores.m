function S = add_edge_scores(S, E, psi, n)
str = time_string();
dlmwrite(sprintf('E_%d_%s.txt', n, str), E, 'delimiter', '\t', 'precision', 3);
fid = fopen(sprintf('LL_%d_%s.txt', n, str), 'w');

for i = 1:length(S)
    for k = 1:length(S{i})
        fprintf(fid, '%d %s %f ', i, num2str(S{i}{k}.parents), S{i}{k}.score);
        s1 = S{i}{k}.score;
        for p = S{i}{k}.parents
            edge = sort([i p]);
            S{i}{k}.score = S{i}{k}.score - psi*E(edge(1), edge(2));
        end
        fprintf(fid, '%f\n', S{i}{k}.score - s1);
    end
end

fclose(fid);
