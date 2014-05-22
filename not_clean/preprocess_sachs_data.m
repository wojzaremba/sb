function [D, labels] = preprocess_sachs_data(plot_flag)

file1 = 'sachs1.csv';
file2 = 'sachs2.csv';
D1 = load(file1);
D2 = load(file2);
labels = [ones(size(D1, 1), 1); 2*ones(size(D2, 1), 1)];
D = [D1; D2];
throw_out = [];

if plot_flag
    plot_sachs_data(D1, D2);
end

% find points to discard
for i = 1 : 11
   X = D(:, i);
   mn = mean(X);
   mx = max(X);
   s = std(X);
   cutoff = mn + 3*s;
   fprintf('Variable %d, mean %.02f, cutoff %.02f, max %.02f\n', i, mn, cutoff, mx);
   throw_out = [throw_out; find(X > cutoff)];
end

% then discard them
all = 1:length(D);
keep = setdiff(all, throw_out);
D = D(keep, :);
labels = labels(keep, :);
numkeep1 = length(find(labels == 1));
numkeep2 = length(find(labels == 2));
assert(numkeep1 + numkeep2 == length(labels));
fprintf('Keeping %d points out of %d points (%d, %d respectively).\n', length(keep), all(end), numkeep1, numkeep2);

% then divide by max
for i = 1 : 11
    X = D(:, i);
    D(:, i) = X / max(X);
end

% plot
if plot_flag
    D1 = D(find(labels == 1), :);
    D2 = D(find(labels == 2), :);
    plot_sachs_data(D1, D2);
end

D = D';
labels = labels';
