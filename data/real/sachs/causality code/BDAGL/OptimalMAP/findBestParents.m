function bps = findBestParents(localScores)

nNodes = size(localScores,1);
bps = zeros(nNodes, 2^nNodes ); % variable sets
bss = zeros(nNodes, 2^nNodes ); % best scores

for ni=1:nNodes
    for si=1:size(bps,2) % loop over all parent sets

        if bitget(si-1, ni), continue; end % can't be a parent of oneself

        bps(ni,si) = si;
        bss(ni,si) = localScores(ni, si);

        bits = bitget(si-1, 1:nNodes);
        for bi=find(bits) % loop over all parents subsets that vary by 1 bit
            ssi = bitset(si-1, bi, 0)+1;
            if bss(ni,ssi)>bss(ni,si)
                bps(ni,si) = bps(ni,ssi);
                bss(ni,si) = bss(ni,ssi);
            end
        end

    end
end