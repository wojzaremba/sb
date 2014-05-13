function compute_kcde_likelihood(S, kernel, emp, family)

emp = emp(family, :);
N = size(emp,2);

for i = 1:length(family)
    child = family(i);
    parents = setdiff(family,child);
    parents_idx = setdiff(1:length(family),i);
    % compute likelihood of data under model parents -> child
    score = 0;
    


    
    if isnan(score)
        assert(0)
    else
        S{child}{end+1} = struct('score',score,'parents',parents);
    end
end