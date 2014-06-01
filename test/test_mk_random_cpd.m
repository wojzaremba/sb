disp('mk_random_cpd...')

seed_rand(1);
arity = 3;
dim = 4;
cpd = mk_random_cpd(arity,dim);
assert(isempty(find(sign(cpd)~=1,1)));

for i = 1:arity
    for j = 1:arity
        for k = 1:arity
            assert(abs(sum(cpd(i,j,k,:)) - 1) < 1e-14);
        end
    end
end

