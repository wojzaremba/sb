function first_greater = compare_curves(x1, y1, x2, y2, numpts)
% check if curve defined by (x1,y1) is consistently higher than curve
% defined by (x2,y2)

if ~exist('numpts','var')
    numpts = 30;
end

[x1, idx] = unique(x1);
y1 = y1(idx);
[x2, idx] = unique(x2);
y2 = y2(idx);

xmin = max(min(x1), min(x2));
xmax = min(max(x1), max(x2));

X = linspace(xmin, xmax, numpts);

Y1 = interp1(x1, y1, X);
Y2 = interp1(x2, y2, X);

first_greater = all(Y1 >= Y2);