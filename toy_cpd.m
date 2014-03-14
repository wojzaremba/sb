C = 1000;
a1 = 3/7 + randn(2*C, 1) / 100;
b1 = 1/6 + randn(2*C, 1) / 100;
c1 = 1/8 + randn(2*C, 1) / 100;
d1 = 1-(a1+b1+c1);
idx_1 = find((d1 >= 0) && (d1 <=1));
idx_1 = idx_1(1:C);
a1 = a1(idx_1);
b1 = b1(idx_1);
c1 = c1(idx_1);
d1 = d1(idx_1);


a2 = 1/7 + randn(2*C, 1) / 100;
b2 = 1/3 + randn(2*C, 1) / 100;
c2 = a2 / (a2 + b2) - a2;
d2 = 1-(a2+b2+c2);
idx_2 = find((d2 >=0) && (d2 <= 1));
idx_2 = idx_2(1:C);
a2 = a2(idx_2);
b2 = b2(idx_2);
c2 = c2(idx_2);
d2 = d2(idx_2);

scatter3(a1,b1,c1,'b');
scatter3(a2,b2,c2,'g');

