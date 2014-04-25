function T = allocate_tensor(arity,dim)
% this creates a tensor of zeros of length arity in each dimension

if dim > 1
string = ['T = zeros(', repmat('arity,',[1 dim]) ';'];
string(end-1) = ')';
eval(string);
elseif dim == 1
    T = zeros(arity,dim);
else
    assert(0);
end