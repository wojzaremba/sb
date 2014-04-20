function [emp,D,p] = generate_random_data(N,arity)

p = sample_dirichlet(ones(arity^2,1),1);
%p = 0.25*ones(4,1);
%p = [ 1 0 0 0];
emp = zeros(2,N);

for t = 1:N
    [x_val,y_val] = ind2sub([arity,arity],find(mnrnd(1,p)));
    emp(1,t) = x_val;
    emp(2,t) = y_val;
end

D = emp_to_dist(emp,arity);


