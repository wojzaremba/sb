function [AUC,flag] = auc(X, Y, xmax, xmin)

if ~exist('xmax','var')
    xmax = 1;
end

if ~exist('xmin','var')
    xmin = 0;
end

printf(2,'xmin = %f\n',xmin);
printf(2,'xmax = %f\n',xmax);

AUC = NaN*ones(size(X,2),size(X,3));
flag = ones(size(X,2),size(X,3));

for i = 1:size(X,2)
    for j = 1:size(X,3)
        x = X(:,i,j);
        y = Y(:,i,j);
        y = y(logical((x <= xmax) .* (x >= xmin)));
        if (length(y) >= 2)
            y = [y(1); y; y(end)];
            x = [xmin; x(logical((x <= xmax) .* (x >= xmin)));  xmax];
            AUC(i,j) = trapz(x,y);
            flag(i,j) = 0;
        end
    end
end