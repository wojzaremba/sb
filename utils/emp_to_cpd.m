function CPD = emp_to_cpd(emp,arity)

CPD = allocate_tensor(arity,size(emp,1));
A = enumerate_assignments(size(emp,1)-2,arity);
N = size(emp,2);
total = 0;

for t = 1:size(A,1)

    % condition on assignment A(t,:)
    cond_emp = condition_emp(emp,A(t,:));
    n = size(cond_emp,2);
    total = total + n;
    
    % inefficient (because cond_emp_to_counts also loops through arity),
    % but will work for now
    counts = cond_emp_to_counts(cond_emp,arity);
    assert(sum(counts(:)) == n);
    for i = 1:arity
        for j = 1:arity
            idx = num2cell(cat(2,[i,j],A(t,:)));
            CPD(idx{:}) = counts(i,j)/n;
        end
    end
   
    printf(3,'finished assignment %d\n',t);
end
printf(3, 'total = %d, N = %d\n', total, N);
assert(total == N);
end

