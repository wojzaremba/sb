function counts = cond_emp_to_counts(cond_emp,arity)
% Takes a list of data points over two variables and counts how many
% instantiations are in each category.  Hence converts from a (2 x
% num_samples) array to an (arity x arity) array.

counts = zeros(arity);
for n = 1:size(cond_emp,2)
    counts(cond_emp(1,n),cond_emp(2,n)) = counts(cond_emp(1,n),cond_emp(2,n)) + 1;
end


