function test_sb_expectation()
disp('test_sb_expectation...');
arity = 3;
P = rand_dist_linear(arity);

% for each N, sample from distribution, 
N = 1000:5000:200000;
err = zeros(1,length(N));

for i = 1:length(N)
    err(i) = sb_expectation_N(P,N(i));
end

should_be_bounded = err.*(N.^2);
assert(max(should_be_bounded) < 100);
%plot(N,should_be_bounded);

end


function err = sb_expectation_N(P,N)
    arity = size(P,1);
    D = sample_N_from_dist(P,N);   
    E = sb_expectation(D,0);
    mi = mutual_information(D./N);
    A = ((arity-1)^2)/(2*N);
    err = abs(E - (mi + A)); % should be O(1/N^2)
end

