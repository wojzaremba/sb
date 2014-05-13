function c = combinations(set, k)

if k == 0
    c = [];
elseif k < 0
    error('k should be >= 0')
else
    c = nchoosek(set, k);
end

% if ~exist('rev', 'var')
%     rev = false;
% end
%
% if rev
%     if ~isempty(b)
%         c = zeros(size(b, 1), length(set) - size(b, 2));
%         b = flipud(b); % so that final order in c makes sense
%         for i = 1 : size(b, 1)
%             c(i, :) = setdiff(set, b(i,:));
%         end
%     else
%         c = set;
%     end
% else
%     c = b;
% end
