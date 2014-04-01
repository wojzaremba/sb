function test_threshold()
disp('test_threshold...');

range = linspace(0,1,6);

rho = 0.5;
classes = threshold(range,rho);
assert(isequal(classes,[0 0 0 1 1 1]'));

rho = [0.5,0.9];
classes = threshold(range,rho);
assert(isequal(classes,[0 0 0 1 1 1; 0 0 0 0 0 1]'));

