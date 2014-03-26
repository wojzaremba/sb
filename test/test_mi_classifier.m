function test_mi_classifier()
    disp('test_mi_classifier...');
    samples_size = 10000;
    emp_indep = [randi(2, 1, samples_size); randi(2, 1, samples_size)];
    opt = struct('arity', 2,'range',[0.001,10]);
    assert(isequal(mi_classifier(emp_indep, opt),[1 1]));
    
    emp_dep = [randi(3, 1, samples_size); randi(2, 1, samples_size)];
    emp_dep(2, emp_dep(1, :) == 3) = 1;
    emp_dep(1, emp_dep(1, :) == 3) = 2;
    
    assert(isequal(mi_classifier(emp_dep, opt),[0 1]));
    
end
