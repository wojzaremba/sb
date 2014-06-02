function [timeCycles timeIsCyclic] = test_isCyclic_addEdge()

timeCycles = 0;
timeIsCyclic = 0;

dagsize = 50;
nReps = 5;
maxFanIn = 20;

mt = 0;
for loop = 1:nReps
    dag1 = mk_rnd_dag(dagsize,maxFanIn);
    dag1 = setdiag(dag1,0);
    
    save('output/dag.mat','dag1');
    for i=1:dagsize
        for j=1:dagsize

            if i==j || dag1(i,j)==1 || dag1(j,i)==1,
                continue;
            end
            
            tic;
            dagAdd = dag1; dagAdd(i,j) = 1;
            ans_cycles = cycles(dagAdd);
            timeCycles = timeCycles + toc;

            tic;
            ans_isCyclic = isCyclic_addEdge(dag1,i,j);
            t2 = toc; mt = max(mt,t2);
            timeIsCyclic = timeIsCyclic + t2;

            if ans_cycles~=ans_isCyclic
                error('inconsistency');
            end
            
        end
        fprintf('row %i [%0.2f %0.2f Max %0.2f]\n', i, timeCycles, timeIsCyclic, mt);
    end
%     i = ceil(rand*dagsize);
%     j = ceil(rand*dagsize);
    
    
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