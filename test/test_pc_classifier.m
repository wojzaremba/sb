
    disp('test_pc_classifier...');
    rand('seed',1);
    randn('seed',1);
    
    sample_size = 10000;
    opt = struct('thresholds',[0.01,1.01]);
        
    Z = randi(5,1,sample_size);
    X = 0.1.*Z + randn(1,sample_size);
    Y = 0.2.*Z + randn(1,sample_size);
    
    emp = [X;Y;Z];
    assert(abs(pc_classifier(emp, [1, 2], opt)-.0411)<1e-3);
    assert(abs(pc_classifier(emp, [1, 2, 3], opt)-.0023)<1e-3);
    

    
    
