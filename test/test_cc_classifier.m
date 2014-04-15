function test_cc_classifier()
    disp('test_cc_classifier...');
    rand('seed',1); % seed random number generator
    samples_size = 10000;
    emp_indep = [randi(2, 1, samples_size); randi(2, 1, samples_size)];
    opt = struct('arity', 2);
    assert(abs(cc_classifier(emp_indep, opt)-.0143)<1e-3);
    
    emp_dep = [randi(3, 1, samples_size); randi(2, 1, samples_size)];
    emp_dep(2, emp_dep(1, :) == 3) = 1;
    emp_dep(1, emp_dep(1, :) == 3) = 2;
    
    assert(abs(cc_classifier(emp_dep, opt)-.2511)<1e-3);
    
    % XXX add symmetric, dependent distribution that has correlation zero
%     P_nonlinear = zeros(3,3);
%     P(1,2) = 0.25;
%     P(2,1) = 0.25;
%     P(2,3) = 0.25;
%     P(3,2) = 0.25;
    

    
end
