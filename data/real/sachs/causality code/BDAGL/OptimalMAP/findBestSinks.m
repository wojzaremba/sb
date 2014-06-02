function sinks = findBestSinks(bps, localScores)

nNodes = size(bps,1);

scores = repmat(0,1,2^nNodes);
sinks = repmat(-1,1,2^nNodes);

for si=1:size(bps,2)

    bits = bitget(si-1, 1:nNodes);
    for sink = find(bits)
       
        upvars = bitset(si-1, sink, 0) + 1;
        skore = scores(upvars);
        skore = skore + localScores(sink, bps(sink, upvars) );
                
        if sinks(si)==-1 || skore > scores(si) 
            scores(si) = skore;
            sinks(si) = sink;
        end 
    end
    
end

