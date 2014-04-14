function mk_linear_cpd_from_cts(numparents,arity)

% generate a discrete CPD based off of X = sum_k alpha_k z_k + epsilon,
% where epsilon is N(0,1/(2*arity)).

num_samples = 1000;
c = NaN;

if (numparents == 1)
    c = 1;
elseif (numparents == 2)
    a = rand(1);
    c = [a (1-a)];
else
    error('numparents should be 1 or 2');
end

z = rand(num_samples,num_parents);
x = z*c' + randn(num_samples,1)/(2*arity);

%discretize