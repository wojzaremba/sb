function CPD = emp_to_cpd(emp,arity)

CPD = allocate_tensor(arity,size(emp,1));
A = enumerate_assignments(size(emp,1)-2,arity);
N = size(emp,2);
total = 0;

for t = 1:size(A,1)

    % condition on assignment A(t,:)
    emp_sub = emp;
    for s = 1:size(A,2)
        emp_sub = emp_sub(:,emp_sub(2+s,:) == A(t,s));
    end
    emp_sub = emp_sub(1:2,:);
    n = size(emp_sub,2);
    total = total + n; % this should add up to N
    
    for i = 1:arity
        for j = 1:arity
            count = length(find(~sum(emp_sub(1:2,:)~=repmat([i j]',1,size(emp_sub,2)),1)));
            idx = num2cell(cat(2,[i,j],A(t,:)));
            CPD(idx{:}) = count/n;
        end
    end
    
    
end
    

            
%             emp_sub = emp(emp(1, :) == i, :, :);
%             emp_sub = emp_sub(:, emp_sub(2, :) == j, :);
%         
%             emp_diff = (emp_sub - repmat(A(t, :), size(emp_sub, 1))) .^ 2;
%             emp_diff = sum(emp_diff, 2);
%             emp_diff = emp_diff ~= 0;
%             CPD(i, j, t) = mean(emp_diff);
%        end
%    end

assert(total == N);
end