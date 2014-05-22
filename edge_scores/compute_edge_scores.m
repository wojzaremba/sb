function [E, info] = compute_edge_scores(emp, opt, maxS, pre)

% number of variables
K = size(emp, 1);

% initialize edge scores
R_norm = zeros(K);
%R_unnorm = zeros(K);

triples = gen_triples(K, [0 : maxS]);
info = cell(length(triples), 1);

if ~exist('pre', 'var')
    if isfield(opt, 'prealloc')
        pre = opt.prealloc(emp, opt);
    else
        pre = [];
    end
end

for t = 1:length(triples)
    i = triples{t}.i;
    j = triples{t}.j;
    [R_norm(i,j), info{t}] = classifier_wrapper(emp, ...
        triples{t}, opt.classifier, opt, pre);  
    %R_unnorm(i,j) = info.Sta_unnorm;
end

%E = -log(R);
R = my_sigmoid(R_norm, 0.05, 20);
E = 1 ./ R_norm;



