disp('test_moralize_dag...');

opt = struct('network', 'Y');
dag = get_dag(opt);

mdag = moralize_dag(dag);

assert(shd(dag, mdag) == 1);
[i j S] = find(mdag - dag);
assert(isequal([i j S], [1 2 1]));

% double V structure with some parents connected in such a way that there is
% only one correct way to induce clique over parents
dag = zeros(4);
dag([1 2 3], 4) = 1;
dag(2, 1) = 1;
dag(3, 2) = 1;

mdag = moralize_dag(dag);
assert(shd(dag, mdag) == 1);
[i j S] = find(mdag - dag);
assert(isequal([i j S], [3 1 1]));



