function [sb_final, opt] = learn_edge_classifier(p, plot_flag)

% throw out p=0 cases- we will just assign sb=0 to such cases
pfull = p;
idx_pos = find(p>0);
p = p(p>0);

% histogram
[counts, x] = hist(p, 30);
width = x(2) - x(1);
h = counts / (sum(counts) * width);
figure
bar(x, h);
hold on;

% approximate p0 via bootstrap
tic;
p0 = mean(bootstrp(200, @p0_approx, p));
fprintf('bootstrapping p0 took %f seconds\n', toc);

% fit the initial width of the "delta" distribution via MLE
dd = 10.^(-4:0.01:-0.5);
opt.p0 = p0;
opt.delta = mle_fit(dd, p, @eval_fd, p0);

% now gridsearch over all three parameters
tic;
lambdas = 10.^(0:0.05:3); %% may want to make this finer
deltas = linspace(opt.delta/2, 2*opt.delta, 10);
aa = linspace(0, 1, 50);
v = zeros(length(lambdas), length(deltas), length(aa));
for i = 1:length(lambdas)
    %opt.lambda = lambdas(i);
    for j = 1:length(deltas)
        %opt.delta = deltas(j);
        for k = 1:length(aa)
            %opt.a = aa(k);
            %v(i, j, k) = sum(log(eval_f3(p, opt)));
            v(i, j, k) = sum(log(eval_f3(p, p0, lambdas(i), deltas(j), aa(k))));
        end
    end
    fprintf('finished i = %d\n', i);
end
[~, ind] = max(v(:));
[i, j, k] = ind2sub(size(v),ind);
lambda = lambdas(i)
delta = deltas(j)
a = aa(k)
toc;

psort = sort(p);
f = eval_f3(psort, p0, lambda, delta, a);
fprintf('AUC = %f\n', auc(psort, f));

% x2 = linspace(0,1);
% beta = prob_H1(x2, p0, lambda);

if (~exist('plot_flag', 'var') || plot_flag)
    plot(psort, f, 'r-', 'linewidth', 2);
    xlim([0,1]);
    ylim([0 100]);
    title('normalized histogram and fit');
%     figure
%     hold on
%     plot(x2, beta, 'b-', 'linewidth', 2);
%     xlabel('p-value');
%     title('Beta scores');
end

% compute betas on original p-values
beta = prob_H1(p, p0, lambda, delta, a);
sb = - log(beta);
sb_final = pfull;
sb_final(idx_pos) = sb;
end

% function [f, f0, f1] = eval_f(p, p0, lambda)
%     if ((~all(p>=0)) || (~all(p<=1)))
%         error('unexpected value for p');
%     end
%     f1 = (1-p0)*lambda*exp(-lambda*p);
%     f0 = p0*ones(size(p));
%     f = f0 + f1;
% end

function [f, f1] = eval_f3(p, p0, lambda, delta, a)
    %[p0, a, lambda, delta] = deal(opt.p0, opt.a, opt.lambda, opt.delta);
    f0 = ones(size(p));
    f11 = lambda * exp(-lambda * p);
    f12 = (1 / delta) .* (p < delta);
    f1 = a * f11 + (1 - a) * f12;
    f = p0 * f0 + (1 - p0) * f1;
end

function f = eval_fd(p, p0, delta)
    f = p0 + (1 - p0) * (1 / delta) .* (p <= delta);
end

function pH1 = prob_H1(x, p0, lambda, delta, a)
    [f, f1] = eval_f3(x, p0, lambda, delta, a);
    pH1 = (1 - p0) * f1 ./ f;
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
