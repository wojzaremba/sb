function [s, mu, sigma] = normalize_data(s, remove_outliers, mu, sigma)

if (~exist('remove_outliers', 'var') || remove_outliers)
    N = size(s, 2);
    ss = s - repmat(median(s, 2), 1, N);
    stdev = std(s, [], 2);
    out = (abs(ss) > repmat(3*stdev, 1, N));
    s = s(:, ~logical(sum(out)));
    printf(2, 'keeping %d out of %d data points\n', size(s, 2), N);
end

if ~exist('mu', 'var')
    mu = mean(s, 2);
    sigma = std(s, [], 2);
end
s = s - repmat(mu, 1, size(s,2));
s = s ./ repmat(sigma, 1, size(s,2));