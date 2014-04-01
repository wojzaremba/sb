function AUC = auc(X,Y,xmax)

if ~exist('xmax','var')
    xmax = 1;
end

printf(2,'setting xmax to %d\n',xmax);

AUC = -1*ones(size(X,2),size(X,3));

for i = 1:size(X,2)
    for j = 1:size(X,3)
        x = X(:,i,j);
        y = Y(:,i,j);
        y = y(x <= xmax);
        y(end+1) = y(end);
        x = [x(x <= xmax); xmax];
        AUC(i,j) = trapz(x,y);
    end
end