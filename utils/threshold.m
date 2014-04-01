function classes = threshold(range,rho)
% returns a binary vector the same length as range, with a 1 in position i
% indicating that rho < range(i), 0 otherwise

%classes = zeros(size(range));
%classes(rho <= range) = 1;

classes = zeros([length(range) size(rho)]);

% i'm sure there's a more efficient way to do this
% FOR NOW JUST HARD_CODE RHO TO BE MAX SIZE 2
for i = 1:size(rho,1)
    for j = 1:size(rho,2)
        classes(rho(i,j)<=range,i,j) = 1;
    end
end

classes = squeeze(classes);

end