function [MI] = mutual_information(P)
% Compute the mutual information of a discrete distribution, P.
% P is a matrix whose entries should all lie between 0 and 1 and sum to 1.

% NOTE: MI is always >= 0, with equality iff X and Y are independent.
% NOTE: This can't handle all distributions (e.g. deterministic).  Don't
% know what to do about this.

[k,l] = size(P);

Px = sum(P,2);
Py = sum(P,1);

MI = 0;
for i = 1:k
    for j = 1:l
        if (P(i,j) ~= 0)
            MI = MI + P(i,j)*log(P(i,j)/(Px(i)*Py(j)));
        end
    end
end

%disp(sprintf('I = %d',MI));
end

