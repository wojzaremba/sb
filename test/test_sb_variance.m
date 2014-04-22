function test_sb_variance()
disp('test_sb_variance...');

arity = 3;
P = rand_dist_linear(arity);

% for each N, sample from distribution, 
N = 10000:10000:50000;
err = zeros(1,length(N));

for i = 1:length(N)
    err(i) = sb_variance_N(P,N(i));
end

assert(max(err) < 1e-6);

end

function err = sb_variance_N(P,N)
    MC_num_samples = 10000;
    D = sample_N_from_dist(P,N);   
    V = sb_variance(D,0);
    V_MC = mi_posterior_monte_carlo(D,MC_num_samples);
    err = abs(V - V_MC);
    printf(2,'   finished N = %d, err = %d\n',N, err);
end
