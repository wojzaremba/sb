function prob = bnetToHistogram(bnet)
% produce a histogram from a bnet (x-axis of histo corresponds to each possible setting of
% variables and their height to the corresponding probability)

bins = zeros(1, prod(bnet.node_sizes));
subs = ind2subv( bnet.node_sizes, 1:length(bins) );

for bi=1:length(bins)
    prob(bi) = log_lik_complete( bnet, subs(bi,:)' );
end

prob = prob - logsumexp(prob);
prob = exp(prob);