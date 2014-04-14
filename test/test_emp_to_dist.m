function test_emp_to_dist()
disp('test_emp_to_dist...');
bnet = mk_bnet4();
K = length(bnet.dag);
arity = get_arity(bnet);

triples = gen_triples(K, 2);

N = 1000;
s = samples(bnet,N);
emp = s(triples{24}, :);

D = emp_to_dist(emp,arity);

for i = 1:size(D,3)
    for j = 1:size(D,4)
        assert( norm(sum(sum(D(:,:,i,j))) - 1) < 1e-4);
    end
end


