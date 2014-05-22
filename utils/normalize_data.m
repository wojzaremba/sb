function s = normalize_data(s, remove_outliers)

if ~exist('remove_outliers', 'var')
    remove_outliers = true;
end

if remove_outliers
    N = size(s, 2);
    ss = s - repmat(median(s, 2), 1, N);
    stdev = std(s, [], 2);
    out = (abs(ss) > repmat(3*stdev, 1, N));
    s = s(:, ~logical(sum(out)));
    printf(2, 'keeping %d out of %d data points\n', size(s, 2), N);
end

s = s - repmat(mean(s,2),1,size(s,2));
s = s ./ repmat(std(s,[],2),1,size(s,2));