function test_cc_classifier()
    disp('test_cc_classifier...');
    samples_size = 100000;
    emp_indep = [randi(2, 1, samples_size); randi(2, 1, samples_size)];
    opt = struct('arity', 2,'range',[0.01,1]);
    assert(isequal(cc_classifier(emp_indep, opt),[1; 1]));
    
    emp_dep = [randi(3, 1, samples_size); randi(2, 1, samples_size)];
    emp_dep(2, emp_dep(1, :) == 3) = 1;
    emp_dep(1, emp_dep(1, :) == 3) = 2;
    
    assert(isequal(cc_classifier(emp_dep, opt),[0; 1]));
    
    % XXX add symmetric, dependent distribution that has correlation zero
%     P_nonlinear = zeros(3,3);
%     P(1,2) = 0.25;
%     P(2,1) = 0.25;
%     P(2,3) = 0.25;
%     P(3,2) = 0.25;
    

    
end
