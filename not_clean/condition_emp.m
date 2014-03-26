function cond_emp = condition_emp(emp,assignment)
% Condition empirical data distribution emp according to assignment

    cond_emp = emp;
    for s = 1:length(assignment)
        cond_emp = cond_emp(:,cond_emp(2+s,:) == assignment(s));
    end
    cond_emp = cond_emp(1:2,:);
