function T = allocate_tensor(arity,dim)
% this creates a tensor of zeros of length arity in each dimension

string = ['T = zeros(', repmat('arity,',[1 dim]) ';'];
string(end-1) = ')';
eval(string);