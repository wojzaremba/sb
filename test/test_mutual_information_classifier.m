function test_mutual_information_classifier()
    samples_size = 10000;
    emp_indep = [randi(2, 1, samples_size); randi(2, 1, samples_size)];
    opt = struct('arity', 2, 'threshold', 0.001);
    assert(mutual_information_classifier(emp_indep, opt) == 0);
    
    emp_dep = [randi(3, 1, samples_size); randi(2, 1, samples_size)];
    emp_dep(2, emp_dep(1, :) == 3) = 1;
    emp_dep(1, emp_dep(1, :) == 3) = 2;
    
    assert(mutual_information_classifier(emp_dep, opt) == 1);
end
