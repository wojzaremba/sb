function [d midpointTime] = samplesToJSDFixedTime(samples, diagnostics, allDags, posterior, increment)
% convert the output of sampleDags*.m to edge marginals
% use the sampler timing -- use all samples up to t1, where t1 is
% increasing by increment

t0 = diagnostics.timing(1);
tEnd = diagnostics.timing(end);

nTicks = ceil((tEnd-t0)/increment);

approxPosterior = zeros(size(posterior));
midpointTime = (1:nTicks)*increment - increment/2;
d = zeros(size(midpointTime));

runningHT = java.util.Hashtable(2^15);

j = 1;
for i=1:nTicks
    while j<=samples.nSamples && (diagnostics.timing(j)-t0)<=(i*increment)
        key = samples.order2DagHT.get( samples.order(j) );
        value = samples.HT.get(key);

        rv = runningHT.get( key );
        if isempty(rv)
            % find index in allDags

            ind = find(all(repmat( uint16(key), length(allDags), 1)==allDags,2));

            % way slower than above vectorized version
            %             for ind=1:length(allDags)
%                 if all(allDags(ind,:)==uint32(key))
%                     break;
%                 end
%             end

            runningHT.put( key, ind);
        else
            ind = rv;
        end

        weight = 1; % order-fix reweighting (only applies for dag samples derived from order samples)
        if length(value)==3, weight = value(3); end

        approxPosterior(ind) = approxPosterior(ind) + weight;
        j = j+1;
    end

    approxPosteriorp = approxPosterior;
    approxPosteriorp = approxPosteriorp / sum(approxPosteriorp);
    d( i ) = JSD(posterior, approxPosteriorp);
end
