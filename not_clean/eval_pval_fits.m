function [S, sb_true, opt_true, true_p0, sb_est, opt_est] = eval_pval_fits()

maxk = 3;

% get "true" values using labels of independence
true_p0 = [];
for i = 1:5
    eval(sprintf('load edge_scores/pval_mats/2014_05_30/child_%d_pvals', i*100));
    S{i} = partition_ps(out);
    figure
    for k = 1:maxk
        A = S{i}{k};
        B = remove_zeros(A);
        true_p0(i, k) = length(find(B.ind)) / length(B.ind);
        C = remove_ind(B);
        assert( (length(B.p) - length(C.p)) / length(B.p) == true_p0(i, k) )
        assert( length(find(C.ind)) == 0)
        subplot(1, maxk, k)
        hold on
        [sb_true{i, k}, opt_true{i, k}] = learn_edge_classifier(C.p, k-1, true);
    end
    suptitle(sprintf('true fits, N=%d', i*100));
end

% and compare with the estimates I would actually use
for i = 1:5
    figure
    for k = 1:maxk
        A = S{i}{k};
        subplot(1, maxk, k)
        hold on
        [sb_est{i, k}, opt_est{i, k}] = learn_edge_classifier(A.p, k-1, true);
    end
    suptitle(sprintf('est fits, N=%d', i*100));
end

for i = 1:5
    fprintf('\n~~ N = %d ~~\n', i*100);
    for k = 1:3
        fprintf('k = %d\n', k-1);
        fprintf('lambda true: %f, est: %f, diff: %f\n', opt_true{i,k}.lambda, opt_est{i,k}.lambda, opt_true{i,k}.lambda - opt_est{i,k}.lambda);
        fprintf('p0 true: %f, est: %f, diff: %f\n', true_p0(i,k), opt_est{i,k}.p0, true_p0(i,k) - opt_est{i,k}.p0);
        fprintf('\n');
    end
end

end

function B = remove_zeros(A)
    keep = find(A.p ~= 0);
    B = keep_vals(A, keep);
end

function C = remove_ind(B)
    keep = find(~B.ind);
    C = keep_vals(B, keep);
end

function B = keep_vals(A, keep)
    B.p = A.p(keep);
    B.sta = A.sta(keep);
    B.edge = A.edge(keep);
    B.ind = A.ind(keep);
end
