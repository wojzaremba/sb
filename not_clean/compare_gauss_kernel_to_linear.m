function compare_gauss_kernel_to_linear(arity)
%[St_lin,St_gauss,S_lin,S_gauss] = 

opt_linear = struct('arity', arity,'kernel',LinearKernel());
opt_gauss = struct('arity', arity,'kernel',GaussKernel());
opt_ind = struct('arity',arity,'kernel',IndKernel());
N = 20;
bnet = mk_asia_linear_gauss(0.5);

for i = 1:100
    %emp = generate_random_data(N,arity);
    s = samples(bnet,N);
    emp = s([4 7],:);
    St_lin = kci_classifier(emp, opt_linear);
    St_gauss = kci_classifier(emp, opt_gauss);
    St_ind = kci_classifier(emp,opt_ind);
    St_cc = cc_classifier(emp,opt_linear);
    %assert(isequal(S_lin,S_gauss));
    %assert(isequal(S_lin,S_ind));
    St_lin - St_gauss
    St_lin - St_ind
    St_lin - St_cc
end
