    disp('test_cc_classifier...');
    rand('seed',1); % seed random number generator
    samples_size = 100000;
    emp_indep = randi(2, 3, samples_size);
    opt_min = struct('arity', 2, 'rho_range', [0 1], 'aggregation', 'min');
    opt_mean = struct('arity', 2, 'rho_range', [0 1], 'aggregation', 'mean');
    assert(cc_classifier(emp_indep, [1, 2], opt_min) < 0.01);
    assert(cc_classifier(emp_indep, [1 2 3], opt_min) < 0.01); 
    
    assert(cc_classifier(emp_indep, [1, 2], opt_mean) < 0.01);
    assert(cc_classifier(emp_indep, [1 2 3], opt_mean) < 0.01);
    
    emp_dep = [randi(3, 1, samples_size); randi(2, 1, samples_size)];
    emp_dep(2, emp_dep(1, :) == 3) = 1;
    emp_dep(1, emp_dep(1, :) == 3) = 2;
    
    assert(cc_classifier(emp_dep, [1, 2], opt_min) > 0.2);
    assert(cc_classifier(emp_dep, [1, 2], opt_mean) > 0.2);
    
    z = sign(rand(1, samples_size) - 0.5);
    x = z .* sign(rand(1, samples_size)-0.9);
    y = -z .* sign(rand(1, samples_size)-0.9);
    emp_dep = [x; y; z];
    emp_dep(emp_dep == -1) = 2;
    assert(cc_classifier(emp_dep, [1, 2], opt_min) > 0.6);
    assert(cc_classifier(emp_dep, [1 2 3], opt_min) < 0.01);
    
    assert(cc_classifier(emp_dep, [1, 2], opt_mean) > 0.6);
    assert(cc_classifier(emp_dep, [1 2 3], opt_mean) < 0.01);
   
