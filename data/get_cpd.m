function CPD = get_cpd(triple,bnet)

% get bnet params
K = length(bnet.dag);
arity = get_arity(bnet);

% extract variables from triple
X = triple(1);
Y = triple(2);
S = triple(3:end);

% set up inference engine
engine = var_elim_inf_engine(bnet);

% Dynamically allocate CPD.
if isnan(S)
    CPD = zeros(arity,arity);
else
    CPD = allocate_tensor(arity,2+length(S));
end

A = enumerate_assignments(length(S),arity);


for t = 1:size(A, 1)
    evidence = cell(1,K);

    for s = 1:length(S)
        evidence{S(s)} = A(t,s);
    end
    
    engine = enter_evidence(engine, evidence);
    m = marginal_nodes(engine, [X Y]);
    CPD(:, :, t) = m.T;
end
