function test_threshold()
disp('test_threshold...');
rho = 0.5;
range = linspace(0,1,6);
classes = threshold(range,rho);
assert(isequal(classes,[0 0 0 1 1 1]));
