% network params
network = 'child';
type = 'quadratic_ggm';
variance = 0.05;

% run params
N = 200;
maxS = 2;
save_flag = true;

bnet = make_bnet(struct('network', network, 'moralize', false, ...
    'arity', 1, 'type', type, 'variance', variance));
si = size(bnet.dag, 1);
kci_opt = struct( 'pval', false, 'kernel', GaussKernel());
triples = gen_triples(size(bnet.dag, 1), 0:maxS);
data = normalize_data(samples(bnet, N));
pre = kci_prealloc(data, kci_opt);

D = ones(si, si, si) * Inf;
for i = 1:si
    D(i, i, i) = norm(pre.K(:, :, i));
    for j = 1:si        
        if (i == j)
            continue;
        end
        for k = j:si
            if (i == k)
                continue;
            end
            K = pre.Kyz(:, :, i, j, k);
            D(i, j, k) = norm(K(:));
            D(i, k, j) = D(i, j, k);            
        end
    end
end

S = cell(size(bnet.dag, 1), 1);
for i = 1:si
    S{i} = {};
    S{i}{end + 1} = struct('score', -D(i, i, i), 'parents', []);      
    for j = 1:si
        if (i == j)
            continue;
        end
        S{i}{end + 1} = struct('score', -D(i, j, j), 'parents', [j]);
        [~, order] = sort(D(i, j, :));
%         for k = 1:5
%             o = order(k);
%             if (D(i, j, o) ~= Inf)
%                 S{i}{end + 1} = struct('score', -D(i, j, o), 'parents', unique([j, o]));
%             end
%         end
    end
end

DAG_pred = run_gobnilp(S);
DAG_true = bnet.dag;

PDAG_pred = dag_to_cpdag(DAG_pred);
PDAG_true = dag_to_cpdag(DAG_true);

hamming_distance = shd(PDAG_pred, PDAG_true);

fprintf('hamming_distance = %d\n', hamming_distance);