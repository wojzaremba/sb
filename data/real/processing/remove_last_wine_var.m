
load wine

for i = 1:10
    D{i}.train = D{i}.train(:, 1:11);
    D{i}.test = D{i}.test(:, 1:11);
end
