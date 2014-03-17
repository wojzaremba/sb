function test_enumerate_assignments()
    A = enumerate_assignments(6,3);
    assert(size(A, 1) == 3^6);
    assert(length(unique(A * (10.^(0:5)'))) == 3^6);
end