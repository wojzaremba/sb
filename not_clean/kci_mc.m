function rho = kci_mc(num_mc, N)

%bn_opt = struct('network', 'chain', 'arity', 1, 'type', 'quadratic_ggm');
randn('seed',1);

G = GaussKernel();
opt = struct('kernel', G);
rho = zeros(1, num_mc);

% indep
for i = 1:num_mc
    x = randn(1,N);
    y = randn(1,N);
    s = normalize_data([x; y]);
    rho(i) = kci_classifier(s, [1 2], opt, []);
    disp(i)
end

hist(rho, 20)
title('independent, unconditional', 'fontsize', 14);

% % independent
% for i = 1:num_mc
%     x = randn(1, N);
%     y = 
