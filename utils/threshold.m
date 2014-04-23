function classes = threshold(thresholds,rho)
% returns a binary vector the same length as thresholds, with a 1 in position i
% indicating that rho < thresholds(i), 0 otherwise

%classes = zeros(size(thresholds));
%classes(rho <= thresholds) = 1;

classes = zeros([length(thresholds) size(rho)]);

% i'm sure there's a more efficient way to do this
% FOR NOW JUST HARD_CODE RHO TO BE MAX SIZE 2
for i = 1:size(rho,1)
    for j = 1:size(rho,2)
        classes(rho(i,j)<thresholds,i,j) = 1;
    end
end

classes = squeeze(classes);

end
