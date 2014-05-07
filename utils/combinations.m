function c = combinations(set, k, rev)

if ~exist('rev', 'var')
    rev = false;
end

if k == 0
    b = [];
elseif k < 0
    error('k should be >= 0')
else
    b = nchoosek(set, k);
end

if rev
    if ~isempty(b)
        c = zeros(size(b, 1), length(set) - size(b, 2));
        b = flipud(b); % so that final order in c makes sense
        for i = 1 : size(b, 1)
            c(i, :) = setdiff(set, b(i,:));
        end
    else
        c = set;
    end
else
    c = b;
end
