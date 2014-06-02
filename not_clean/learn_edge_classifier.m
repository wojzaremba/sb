function [sb, p0, lambda, f, f0, f1, v] = learn_edge_classifier(p, plot_flag)

% throw out p=0 cases- we will just give sb=0 to such cases
p_full = p;
p = p(p>0);

% approximate p0 via bootstrap
tic;
p0 = mean(bootstrp(200, @p0_approx, p));
fprintf('bootstrapping p0 took %f seconds\n', toc);

% histogram
[counts, x] = hist(p, 30);
width = x(2) - x(1);
h = counts / (sum(counts) * width);

% choose lambda
%dd = 10.^(-4:0.2:-0.6); deltas 
lambdas = 10.^(0:0.01:10); 
v = zeros(size(lambdas));
for j=1:length(lambdas)
    v(j) = sum(log(eval_f(p, p0, lambdas(j)))); % log-likelihood
    %f = eval_f(x, p0, lambdas(j));
    %v(j) = (norm(f - h))^2; % residuals
end

[~, best] = max(v);
lambda = lambdas(best);

psort = sort(p);
[f, f0, f1] = eval_f(psort, p0, lambda);
fprintf('AUC = %f\n', auc(psort, f));
x2 = linspace(0,1);
beta = eval_beta(x2, p0, lambda);

if (~exist('plot_flag', 'var') || plot_flag)
    figure
    hold on
    plot(psort, f, 'r-', 'linewidth', 2);
    plot(x, h, 'k-');
    xlim([0,1]);
    legend('final','hist');
    figure
    hold on
    plot(x2, beta, 'b-', 'linewidth', 2);
    xlabel('p-value');
    title('Beta scores');
end

% compute betas on original p-values
beta = eval_beta(p, p0, lambda);
sb = - log(beta);

end

function [f, f0, f1] = eval_f(p, p0, lambda)
    if ((~all(p>=0)) || (~all(p<=1)))
        error('unexpected value for p');
    end
    %f = p0 + ((1 - p0) / lambda).*(p <= lambda);
    f1 = (1-p0)*lambda*exp(-lambda*p);
    f0 = p0*ones(size(p));
    f = f0 + f1;
end

function beta = eval_beta(x, p0, lambda)
    [f, ~, f1] = eval_f(x, p0, lambda);
    beta = (1 - p0) * f1 ./ f;
end

function p0 = p0_approx(p)
    ind_counts = length(find(p > 0.5))*2;
    p0 = ind_counts / length(p);
end
