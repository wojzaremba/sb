disp('test_compare_curves...');

rand('seed', 1);

x1 = rand(1,50);
x1 = sort(x1);
y1 = sqrt(x1);

x2 = rand(1,50);
x2 = sort(x2);
y2 = x2;

assert(compare_curves(x1, y1, x2, y2));
