function test_kci_classifier()
    disp('test_kci_classifier...');
    global debug
    debug=2;
    
    rand('seed', 1);
    randn('seed',1);
    samples_size = 1000;
    emp_indep = [randi(2, 1, samples_size); randi(2, 1, samples_size)];

%     emp_dep = [randi(3, 1, samples_size); randi(2, 1, samples_size)];
%     emp_dep(2, emp_dep(1, :) == 3) = 1;
%     emp_dep(1, emp_dep(1, :) == 3) = 2;
    x = randn(1,samples_size);
    y = x.^2 + randn(1,samples_size);
    emp_dep = [x; y];
    emp_dep = discretize(emp_dep,5);
    
    printf(2,'  linear kernel...\n');
    opt = struct('arity', 2,'kernel',LinearKernel());
    assert(abs(kci_classifier(emp_indep, opt)-6.73e-4)<1e-5);
    assert(abs(kci_classifier(emp_dep, opt)-6.31e-4)<1e-5);

    printf(2,'  gauss kernel...\n');
    opt.kernel = GaussKernel();
    assert(abs(kci_classifier(emp_indep, opt) - 6.73e-4)<1e-5);
    assert(abs(kci_classifier(emp_dep, opt)-.0964)<1e-3);
    
    
    