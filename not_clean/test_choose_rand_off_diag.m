function dummy()
assert(0)
-d function dummy()\nassert(0)
function test_choose_rand_off_diag()

for k = 1:1000
    A = allocate_tensor(2,3);
    diag(A) = 1;
    idx = choose_rand_off_diag(size(A));
    A(idx) = 1;
    assert(length(find(unique(A(:)))) == 2);
    assert(length(find(A(:))) == 3);
    idx
end