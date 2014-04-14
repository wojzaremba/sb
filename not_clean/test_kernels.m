function [ind,gauss] = test_kernels()

arity = 10;
N = 200;
x = randi(arity,N);
b = randn(N);
b(b==2) = -1;
y = x + b;

emp = [x'; y'];

Ind = IndKernel();
G = GaussKernel();

opt = struct('arity',arity ,'kernel',Ind,'range',0:1e-3:1);
%assert(isequal(kci_classifier(emp, opt),[0; 1]));
ind = kci_classifier(emp,opt);

opt.kernel = G;
%assert(isequal(kci_classifier(emp, opt),[0; 1]));
gauss = kci_classifier(emp,opt);
 