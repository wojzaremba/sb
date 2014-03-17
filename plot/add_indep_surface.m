
a = linspace(0,1,30);
b = linspace(0,1,30);
[B,A] = meshgrid(a,b);

S = NaN*ones(size(A));

for i = 1:length(a)
    for j = 1:length(b)
        c = a(i)/(a(i)+b(j)) - a(i);
        if (a(i) + b(j) + c <= 1)
            S(i,j) = c;
        end
    end
end

hold on
surf(A, B, S,'Facecolor','g');
alpha(0.4);
%axis off;
grid off;


