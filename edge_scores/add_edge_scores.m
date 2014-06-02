function S = add_edge_scores(S, E, psi, n)

%fid = fopen(sprintf('sb3_%d.txt', n),'a');

for i = 1:length(S)
    for k = 1:length(S{i})
        S1 = S{i}{k}.score;
%        fprintf(fid, '%f ', S1);
        for p = S{i}{k}.parents
            edge = sort([i p]);
            S{i}{k}.score = S{i}{k}.score - psi*E(edge(1), edge(2));
        end
%        fprintf(fid, '  %f\n', S{i}{k}.score - S1);
    end
end

fclose(fid);
