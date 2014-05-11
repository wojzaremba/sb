function weight = computeDagWeight(dags, orders)

[uniqueDags dco] = uniqueDagSamples(dags);
[uniqueOrders oco] = uniqueOrderSamples(orders);

uweight = zeros(1,length(uniqueDags));
for di=1:length(uniqueDags)
    for oi=1:size(uniqueOrders,1)
        uweight(di) = uweight(di) + isDagOrderConsistent( uniqueDags{di}, uniqueOrders(oi,:) );
    end
end
uweight = 1./uweight;

weight = zeros(1, length(dags));
for di=1:length(dags)
   for udi=1:length(uniqueDags)
       if all( dags{di}==uniqueDags{udi} ), break; end
   end
   weight(di) = uweight(udi);
end