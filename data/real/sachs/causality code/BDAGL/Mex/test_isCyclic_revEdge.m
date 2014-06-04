function [timeCycles timeIsCyclic] = test_isCyclic_addEdge()

timeCycles = 0;
timeIsCyclic = 0;

dagsize = 250;
nReps = 5;
maxFanIn = 7;

mt = 0;
for loop = 1:nReps
    dag1 = mk_rnd_dag(dagsize,maxFanIn);
    dag1 = setdiag(dag1,0);

    [i j] = find(dag1);
    
    mean(sum(dag1))
    
    for ei=1:length(i)

        tic;
        adjMatrix_rev = dag1;
        adjMatrix_rev(i(ei),j(ei)) = 0;
        adjMatrix_rev(j(ei),i(ei)) = 1;
        ans_cycles = cycles(adjMatrix_rev);
        timeCycles = timeCycles + toc;

        tic;
        ans_isCyclic = isCyclic_revEdge(dag1,i(ei),j(ei));
        t2 = toc; mt = max(mt,t2);
        timeIsCyclic = timeIsCyclic + t2;

        if ans_cycles~=ans_isCyclic
            error('inconsistency');
        end

        if mod(ei,10)==0
            fprintf('%i [%0.2f %0.2f Max %0.2f]\n', ei, timeCycles, timeIsCyclic, mt);
        end
    end
    
    
    if mod(loop,1)==0
        fprintf('%i of %i\n', loop, nReps);
    end
    
end

end

% Returns 1 if the graph has cycles
function [c] = cycles(adjMatrix)
p = length(adjMatrix);
c = sum(diag((sparse(adjMatrix+eye(p)))^p) == ones(p,1)) ~= p;
end