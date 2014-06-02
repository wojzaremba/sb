disp('test_flatten_loop...')

pair = flatten_loop(5,3);

assert(length(pair)) = 15;
assert(pair{5}.i == 2);
assert(pair{5}.j == 2);