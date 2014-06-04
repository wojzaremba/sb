load SEMdata_8_2.mat
X = X2;
X(X==-1) = 2;
A = A2;
targets = A2;
save('SEMdata_8_2_visible.mat','X','A','targets','adj');
X = X3;
X(X==-1) = 2;
A = A3;
save('SEMdata_8_2_hidden.mat','X','A');

load SEMdata_8_3.mat
X = X2;
X(X==-1) = 2;
A = A2;
targets = A2;
save('SEMdata_8_3_visible.mat','X','A','targets','adj');
X = X3;
X(X==-1) = 2;
A = A3;
save('SEMdata_8_3_hidden.mat','X','A');

load SEMdata_10_3.mat
X = X2;
X(X==-1) = 2;
A = A2;
targets = A2;
save('SEMdata_10_3_visible.mat','X','A','targets','adj');
X = X3;
X(X==-1) = 2;
A = A3;
save('SEMdata_10_3_hidden.mat','X','A');

load SEMdata_10_8.mat
X = X2;
X(X==-1) = 2;
A = A2;
targets = A2;
save('SEMdata_10_8_visible.mat','X','A','targets','adj');
X = X3;
X(X==-1) = 2;
A = A3;
save('SEMdata_10_8_hidden.mat','X','A');
