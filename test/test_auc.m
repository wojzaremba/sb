function test_auc()
disp('test_auc...');

x = linspace(0,1,1000)';
y = x.^2;

assert(abs(auc(x,y) - 1/3) < 1e-3);

assert(abs(auc(x,y,0.05) - 4.1667e-05) < 1e-3);
