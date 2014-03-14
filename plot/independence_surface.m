
a = linspace(0,1,30);
b = linspace(0,1,30);
[A,B] = meshgrid(a,b);

S = NaN*ones(size(A));
P1 = NaN*ones(size(A));

for i = 1:length(a)
    for j = 1:length(b)
        c = a(i)/(a(i)+b(j)) - a(i);
        if (a(i) + b(j) + c <= 1)
            S(i,j) = c;
        end
        if (1 - a(i)-b(j) >= 0)
            P1(i,j) = 1 - a(i)-b(j);
        end
    end
end


%surf(A,B,P1,'linestyle','none','facecolor','c');
%hold on;
%alpha(0.4);
C = del2(S);
simp=[0 0 0; 0 0 1; 0 1 0; 0 0 0; 0 1 0; 1 0 0; 0 0 0; 1 0 0; 0 0 1; 0 0 0];

% Label the axes manually and have MatLab retain all previous drawings:
%axis([-1.2 1.2  -1.2 1.2  -1.2 1.2]); axis manual; hold on;

% Plot the 3-simplex in its initial position.
plot3(simp(:,1), simp(:,2), simp(:,3),'k','linewidth',2);
hold on;
surf(A,B,S,'Facecolor','g');
alpha(0.4);
%surf(A,B,S,C);
axis off;


fontsize = 18;
xlabel('a','fontsize',fontsize);
ylabel('b','fontsize',fontsize);
zlabel('c','fontsize',fontsize);
title('Manifold of Independence','fontsize',16);
%xlim([-1,1]);
%ylim([-1,1]);
grid off;


