function p = my_sigmoid(x, offset, multiplier)

if ~exist('multiplier','var')
    multiplier = 1;
end

if ~exist('offset', 'var')
    offset = 0;
end

p = 1./(1+exp(-multiplier*(x - offset)));