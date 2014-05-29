
S = {};

i = 1;
for n = nvec
    file = sprintf('sb3_%d.txt', n);
    S{end+1} = load(file);
    rho(:, i) = S{end}(:, 1);
    edge(:, i) = S{end}(:, 2);
    i = i + 1;
end

plot(mean(rho))
plot(nvec, mean(rho), 'b-');
hold on;
plot(nvec, mean(edge), 'r-');



