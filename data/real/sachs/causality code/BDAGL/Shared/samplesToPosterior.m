function post = samplesToPosterior(samples, allDags )

post = zeros(1, length(allDags));

keys = samples.HT.keys;

j = 0;
while keys.hasMoreElements()

    key = keys.nextElement();
    value = samples.HT.get(key);

    weight = value(1); % order-fix reweighting (only applies for dag samples derived from order samples)
    if length(value)==3, weight = weight*value(3); end
% 
%     weight
%     if weight < 20
%         continue;
%     end
    
   ind = find(all(repmat( uint16(key), length(allDags), 1)==allDags,2));

   post(ind) = post(ind) + weight;

    j = j + 1;
    if mod(j, 50)==0
        fprintf('%i/%i\n', j, samples.HT.size);
    end

end

post = post / sum(post);