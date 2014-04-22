disp('test_cond_emp_to_counts...');

arity = 3;
emp = randi(arity,4,300);

A = enumerate_assignments(size(emp,1)-2,arity);
N = size(emp,2);
total = 0;
counts = zeros(arity);

for t = 1:size(A,1)

    % condition on assignment A(t,:)
    cond_emp = condition_emp(emp,A(t,:));
    n = size(cond_emp,2);
    total = total + n; % this should add up to N
    
    % count 
    counts = cond_emp_to_counts(cond_emp,arity);
    assert(sum(counts(:)) == n);
    
end
