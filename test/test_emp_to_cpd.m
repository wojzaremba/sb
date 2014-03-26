function test_emp_to_cpd()
disp('test_emp_to_cpd...');
bnet = mk_bnet4();
K = length(bnet.dag);
arity = get_arity(bnet);

triples = gen_triples(K, 2);

N = 1000;
s = samples(bnet,N);
emp = s(triples{24}, :);

CPD = emp_to_cpd(emp,arity);

for i = 1:size(CPD,3)
    for j = 1:size(CPD,4)
        assert( sum(sum(CPD(:,:,i,j))) == 1);
    end
end


