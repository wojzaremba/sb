disp('test_allocate_tensor...');
T = allocate_tensor(4,3);
assert(length(T(:))==4^3);
