function test_sample_N_from_dist()
disp('test_sample_N_from_dist...');

N = 1000:10000:1000000;
err = zeros(1,length(N));

arity = 3;
P = rand_dist_linear(arity);

for i = 1:length(N)
    D = sample_N_from_dist(P,N(i));
    D = D ./ sum(D(:));
    err(i) = norm(D - P);
end

assert(mean(err) < 0.01);
