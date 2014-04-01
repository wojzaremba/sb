function D = sample_N_from_dist(P,N)
%SAMPLE_N Samples N data points from P, returns it in an array formatted
%like P.

bins = [0; cumsum(P(:))];
vec = rand(N,1);
n = histc(vec,bins);
%D1 = [n(1) n(3); n(2) n(4)];
D = reshape(n(1:end-1),size(P));

end

