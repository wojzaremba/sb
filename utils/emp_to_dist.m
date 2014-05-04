function D = emp_to_dist(emp, arity, normalize)

if ~exist('normalize','var')
   normalize = true; 
end

num_vars = size(emp,1);
N = size(emp,2);
D = allocate_tensor(arity, num_vars);

if num_vars >= 3
    counts = allocate_tensor(arity, num_vars - 2);
elseif (num_vars == 1 || num_vars == 2)
    counts = N;
else
    assert(0)
end

% construct command of the form "D(emp(1,n), emp(2,n), emp(3,n)) =
% D(emp(1,n), emp(2,n), emp(3,n)) + 1" where the 3 corresponds to num_vars
estr = sprintf('emp(%d,n), ',1:num_vars);
dstr = ['D(' estr(1:end-2) ')'];
command_D = [dstr ' = ' dstr ' + 1;'];

% construct command of the form "counts(emp(3,n)) = counts(emp(3,n)) + 1",
% where again 3 corresponds to num_vars
if num_vars >=3
    estr2 = sprintf('emp(%d,n), ', 3:num_vars);
    cstr = ['counts(' estr2(1:end-2) ')'];
    command_c = [cstr ' = ' cstr ' + 1;'];
else
    command_c = '';
end

command = sprintf('for n = 1:N %s %s end',command_D, command_c);
eval(command);

% normalize
if normalize
    A = enumerate_assignments(num_vars-2, arity);
    for t = 1:size(A, 1)
        idx = num2cell(A(t,:));
        D(:,:,idx{:}) = D(:,:,idx{:}) ./ counts(idx{:});
    end
end


end