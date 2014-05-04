function [dep, indep, all, data_cts] = learn_dependence()

variance = 0.05;
network = 'asia';
type = 'quadratic_ggm';
arity = 1; % if greater than 1, will discretize, otherwise will keep continuous

bn_opt = struct('variance', variance, 'network', network, 'arity', 1, 'type', type);
bnet = make_bnet(bn_opt);

data_cts = normalize_data(samples(bnet, 500));
data = discretize_data(data_cts, arity);

K = size(data, 1);

theta_dep = ones(arity, arity);
theta_indep = ones(arity, arity);
cnt = 0;

for i = 1:K
    for j = i+1:K
        sub = data([i j],:);
        counts = emp_to_dist(sub, arity, false);
        if ~dsep(i,j,[],bnet.dag) % only look at the dependent distributions
            theta_dep = theta_dep + counts;
        else
            theta_indep = theta_indep + counts;
            cnt = cnt + 1;
        end
    end
end

theta_all = theta_dep + theta_indep;

indep = theta_indep / sum(theta_indep(:));
dep = theta_dep / sum(theta_dep(:));
all = theta_all / sum(theta_all(:));

fprintf('diff to dep: %f\n', norm(dep - all));
fprintf('diff to indep: %f\n', norm(indep - all));



