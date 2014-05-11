function [errors] = getDAGerrors(dagT,dagQ,convertToPDAG)
% computes PDAG errors for comparing query DAG to true DAG

if convertToPDAG
    pdag = dag_to_cpdag(dagT);
end

if convertToPDAG
    errors = 0;
    for i = 1:length(dagQ)
        for j = 1:length(dagQ)
            if dagQ(i,j) ~= pdag(i,j)
                % Mismatch between dag and pdag at (i,j)

                if pdag(i,j)+pdag(j,i) == 0
                    % Erroneous Edge
                    errors = errors+1;
                elseif pdag(i,j)+pdag(j,i) == 1
                    % Directed Edge
                    if dagQ(i,j) + dagQ(j,i) == 0
                        % Missing Edge
                        errors = errors+1;
                    else
                        % Reversed Edge
                        errors = errors + 1/2; % Counted twice
                    end
                else
                    % Undirected Edge
                    if dagQ(i,j)+dagQ(j,i) == 0
                        % Missed Edge
                        errors = errors + 1/2; % Counted twice
                    end
                end

            end
        end
    end
else
    errors = sum(sum(abs(dagT - dagQ)));
end