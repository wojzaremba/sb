function marginals = empiricalEdgeMarginals_DagsOld(dagSamples, counts, weight)

if nargin<2
    [uniqueDags counts] = uniqueDagSamples(dagSamples);
else
    uniqueDags = dagSamples;
end

if nargin<3
    weight = ones(1,length(uniqueDags));
end

counts = counts .* weight;
counts = counts / sum(counts);

marginals = zeros(length(dagSamples{1}));
for di=1:length(uniqueDags)
    marginals = marginals + uniqueDags{di}*counts(di);
end