function v = extract_vector(C,b)
% extract vector from C specificed by the 0 in b, fixing the other
% dimensions of C according to b
%
% length(b) should be length(size(C))

assert(length(b) == length(find(size(C) ~= 1)));

str = '';
for i = 1:length(b)
    if b(i) == 0
        str = [str ':, '];
    else
        str = [str num2str(b(i)) ', '];
    end
end
str = str(1:end-2);
command = sprintf('squeeze(C(%s))',str);
v = eval(command);
