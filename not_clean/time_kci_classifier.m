disp('numerator sums:');
tic
for i = 1:100
    a = abs(sum(Kx(:) .* Ky(:)));
end
toc

disp('numerator trace:');
tic
for i = 1:100
    b = trace(Kx*Ky);
end
toc

disp('denominator sums:');
tic
for i = 1:100
    d = sum(diag(Kx)) * sum(diag(Ky));
end
toc

disp('denominator trace:');
tic
for i = 1:100
    c = trace(Kx)*trace(Ky);
end
toc





    