function write_gobnilp_scores(file, S)

score = '';
fid = fopen(file, 'w');
nodes = size(S, 1);
fprintf(fid, '%d\n', nodes);
for i = 1:nodes
    fprintf(fid, '%d %d\n', i - 1, length(S{i}));
    for j = 1:length(S{i})
        fprintf(fid, '%f %d ', S{i}{j}.score, length(S{i}{j}.parents));
        for p = 1:length(S{i}{j}.parents)
            fprintf(fid, '%d ', S{i}{j}.parents(p)-1);
        end
        fprintf(fid, '\n');
    end
end
%fprintf(fid, score);
fclose(fid);