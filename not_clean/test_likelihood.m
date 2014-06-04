function test_likelihood(train, test)

nvars = size(train, 1);
fid = fopen('LL2','w');

for i = 1:nvars
   for j = 1:nvars
       if j ~= i
           LL = compute_kernel_ridge_likelihood(i, j, train, test);
           %LL = save_kernel_likelihood(i, j, train, test);
           fprintf(fid, '%d %d %f\n', i, j, LL);
       end
   end
end

fclose(fid);