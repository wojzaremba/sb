function CPD = gen_cpd_dist(bnet)

addpath(genpath('.'));
N = length(bnet.dag);
engine = var_elim_inf_engine(bnet);
evidence = cell(1,N);
engine = enter_evidence(engine, evidence);

max_cond_size = min(3,N-2);
CPD = zeros(2, 2, 0);

arity = unique(bnet.node_sizes);
fprintf('arity = %d',arity);
if length(arity) > 1
    error('All variables should have the same number of states');
end

print = true;

for i = 1:N
    for j = i+1:N
        
        fprintf('i=%d, j=%d\n',i,j);

        for k = 0:max_cond_size
            set = [1:(i-1) (i+1):(j-1) (j+1):N];
            cond_sets = combinations(set, k);
            for c = 1:size(cond_sets, 1)
                for t = 0:(arity^k-1)                       % go through each possible assignment to the conditioning set (assuming all variables are binary)
                    evidence = cell(1,N);               % clear evidence
                    for v = 1:k
                        % take v-th variable and assign assignment
                        % either 1 or 2, depending on whether the v'th
                        % place in the binary representation of t is a 0 or
                        % 1
                        evidence{cond_sets(c,v)} = bitand(t,2^(v-1))/2^(v-1) + 1;
                    end
                    engine = enter_evidence(engine, evidence);                   
                    m = marginal_nodes(engine, [i j]); 
                    CPD(:,:,end+1) = m.T;
                    
                    if (print)
                        disp(sprintf('marginal over %d,%d conditioning on... ',i,j));
                        cond_sets(c,:)
                        evidence
                        fprintf('size of m.T is [%d,%d])\n',size(m.T));
                        fprintf('size of CPD(end,:,:) is [%d,%d,%d]\n',size(CPD(end,:,:)));
                    end
                    
                end
            end
        end
    end
end
