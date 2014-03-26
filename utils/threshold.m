function classes = threshold(range,rho)
% returns a binary vector the same length as range, with a 1 in position i
% indicating that rho < range(i), 0 otherwise

classes = zeros(size(range));
classes(rho < range) = 1;

end