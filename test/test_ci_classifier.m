function test_ci_classifier()

    disp('test_ci_classifier...');
    sample_size = 100000;
    opt = struct('range',[0.01,1.01]);
        
    Z = randi(5,1,sample_size);
    X = 0.1.*Z + randn(1,sample_size);
    Y = 0.2.*Z + randn(1,sample_size);
    
    emp = [X;Y;Z];
    
    assert(isequal(ci_classifier(emp(1:2,:), opt),[0 1]));
    assert(isequal(ci_classifier(emp, opt),[1 1]));
    

    
    