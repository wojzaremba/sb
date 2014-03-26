function test_condition_emp()

arity = 2;
emp = randi(arity,4,100);
A = enumerate_assignments(size(emp,1)-2,arity);
N = size(emp,2);
total = 0;

for t = 1:size(A,1)

    % condition on assignment A(t,:)
    cond_emp = condition_emp(emp,A(t,:));
    n = size(cond_emp,2);
    total = total + n; % this should add up to N
    
end
printf(3, 'total = %d, N = %d\n', total, N);
assert(total == N);

end