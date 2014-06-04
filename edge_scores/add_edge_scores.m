function S = add_edge_scores(S, E, psi)

for i = 1:length(S)
    for k = 1:length(S{i})
        printf(2, '%d given %s LL=%f,', i, num2str(S{i}{k}.parents), S{i}{k}.score);
        s1 = S{i}{k}.score;
        for p = S{i}{k}.parents
            edge = sort([i p]);
            S{i}{k}.score = S{i}{k}.score - psi*E(edge(1), edge(2));
        end
        printf(2, 'SB=%f\n', S{i}{k}.score - s1);
    end
end

