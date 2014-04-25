function S = compute_bic_family(S, emp, family, arity)
% CURRENTLY JUST COMPUTES (MAXIMUM) LOG-LIKELIHOOD

emp = emp(family, :);

% counts over family
C = emp_to_dist(emp, arity, false);
A = enumerate_assignments(length(family)-1, arity);
b = zeros(1, length(family));
N = size(emp,2);

for i = 1:length(family)
    child = family(i);
    parents = setdiff(family,child);
    parents_idx = setdiff(1:length(family),i);
    % compute likelihood of data under model parents -> child (with MLE
    % parameters)
    score = 0;
    num_parent_settings = size(A,1);
    b = zeros(1, length(family));
    for k = 1:num_parent_settings
        b(parents_idx) = A(k,:);
        C_ik = extract_vector(C,b);
        N_ik = sum(C_ik);
        for j = 1:arity
            score = score + C_ik(j)*log(C_ik(j)/N_ik);
        end
    end
    score = score - 0.5*log(N)*(num_parent_settings*(arity - 1));
    S{child}{end+1} = struct('score',score,'parents',parents);
end
    