disp('test_emp_to_dist...');
bnet = mk_bnet4();
K = length(bnet.dag);
arity = get_arity(bnet);

triples = gen_triples(K, 2);

N = 1000;
s = samples(bnet,N);
emp = s([triples{end}.i triples{end}.j triples{end}.cond_set{end}], :);

% tic;
% num_reps = 20;
% for i = 1:num_reps
% D = emp_to_dist(emp,arity);
% end
% time = toc;
% fprintf('avg compute time is %f\n',time/num_reps);


for i = 1:size(D,3)
    for j = 1:size(D,4)
        assert( norm(sum(sum(D(:,:,i,j))) - 1) < 1e-4);
    end
end


