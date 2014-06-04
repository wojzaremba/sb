function [sb_final, opt] = learn_edge_classifier(p, plot_flag)

% throw out p=0 cases- we will just assign sb=0 to such cases
pfull = p;
idx_pos = find(p>0);
p = p(p>0);

% histogram
if plot_flag
    figure
    [counts, x] = hist(p, 40);
    width = x(2) - x(1);
    g = counts / (sum(counts) * width);
    bar(x, g, 'linestyle', 'none');
    hold on;
end

% approximate p0 via bootstrap
tic;
p0 = mean(bootstrp(200, @p0_approx, p));
fprintf('bootstrapping p0 took %f seconds\n', toc);

% fit the initial width of the "delta" distribution via MLE
dd = 10.^(-3:0.01:-1);
opt.p0 = p0;
opt.delta = mle_fit(dd, p, @eval_fd, p0);

% now gridsearch over all three parameters
tic;
lambdas = 10.^(0:0.05:3); %% may want to make this finer
deltas = linspace(opt.delta/2, 2*opt.delta, 10);
aa = linspace(0, 1, 50);
v = zeros(length(lambdas), length(deltas), length(aa));
for i = 1:length(lambdas)
    for j = 1:length(deltas)
        for k = 1:length(aa)
            v(i, j, k) = sum(log(eval_f3(p, p0, lambdas(i), deltas(j), aa(k))));
        end
    end
    fprintf('finished i = %d\n', i);
end
[~, ind] = max(v(:));
[i, j, k] = ind2sub(size(v),ind);
opt.lambda = lambdas(i);
opt.delta = deltas(j);
opt.a = aa(k);
toc;


x = [linspace(0, 1e-1, 10000) linspace(1e-1, 1, 10)];
[f, f1] = eval_f3_opt(x, opt);
fprintf('AUC = %f\n', auc(x', f'));

if (~exist('plot_flag', 'var') || plot_flag)
    h(1) = plot(x, f, 'm.-', 'linewidth', 3);
    h(2) = plot(x, f - (1 - opt.p0)*f1, 'r--', 'linewidth', 3);
    h(3) = plot(x, (1 - opt.p0)*f1, 'b-', 'linewidth', 3);
    plot(x, f, 'm.-', 'linewidth', 3);
    xlim([0,1]);
    ylim([0 4]);
    %title(sprintf('Cond sets size %d',set_size), 'fontsize', 16);
    l = legend(h, 'f', 'f0', 'f1');
    set(l, 'fontsize', 16);
    xlabel('p-value', 'fontsize', 16);
    ylabel('f(p)', 'fontsize', 16);
end

% compute betas on original p-values
beta = prob_H1(p, opt);
sb = - log(beta);
sb_final = pfull;
sb_final(idx_pos) = sb;
end

function [f, f1] = eval_f3_opt(p, opt)
    [p0, lambda, delta, a] = deal(opt.p0, opt.lambda, opt.delta, opt.a);
    [f, f1] = eval_f3(p, p0, lambda, delta, a);
end

function [f, f1] = eval_f3(p, p0, lambda, delta, a)
    f0 = ones(size(p));
    f11 = lambda * exp(-lambda * p);
    f12 = (1 / delta) .* (p < delta);
    f1 = a * f11 + (1 - a) * f12;
    f = p0 * f0 + (1 - p0) * f1;
end

function f = eval_fd(p, p0, delta)
    f = p0 + (1 - p0) * (1 / delta) .* (p <= delta);
end

function pH1 = prob_H1(x, opt)
    [f, f1] = eval_f3_opt(x, opt);
    pH1 = (1 - opt.p0) * f1 ./ f;
end

function p0 = p0_approx(p)
    ind_counts = length(find(p > 0.5))*2;
    p0 = ind_counts / length(p);
end

function param = mle_fit(paramvec, data, func, p0)
    v = zeros(size(paramvec));
    for j = 1:length(v)
        v(j) = sum(log(func(data, p0, paramvec(j))));
    end
    [~, best] = max(v);
    param = paramvec(best);
end
