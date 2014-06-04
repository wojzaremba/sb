function out = bn_learn_real(in)

[rp, learn_opt, D, LL, T, G] = init(in);
[ll, time] = deal(zeros(rp.folds, 1));

for t = 1:length(learn_opt)
    opt = learn_opt{t};
    for ni = 1:length(rp.nvec)
        n = rp.nvec(ni);
        for fold = 1:rp.folds
            data = sample_n(D{fold}.train, n);
            [G{t, fold, ni}, time(fold)] = ...
                learn_structure(data, opt, rp, n); 
            ll(fold) = compute_likelihood_G(G{t, fold, ni}, ...
                D{fold}.train, D{fold}.test); 
            printf(2, 'fold=%d, LL=%f\n', fold, ll(fold));
        end
        [LL{t}, T{t}] = populate_LL_T(LL{t}, T{t}, ll, time, ni);
        update_plot(LL, T, t, ni, rp, learn_opt);
    end
end

[out.LL, out.T, out.G, out.rp, out.learn_opt] = deal(LL, T, G, rp, learn_opt);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is a kluge to be able to run parfor.
function [LL,T] = populate_LL_T(LL, T, ll, time, ni)
    LL(:, ni) = ll;
    T(:, ni) = time;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Dn = sample_n(D, n)
    N = size(D, 2);
    assert(n <= N);
    select = randsample(N, n);
    Dn = D(:, select);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function update_plot(LL, T, tmax, nmax, rp, learn_opt)
    if rp.plot_flag
        figure(1)
        hold on
        n = rp.nvec(1:nmax);
        [h1, h2] = deal(zeros(1, tmax));
        
        for t = 1:tmax
            subplot(1, 2, 1)
            hold on
            L = squeeze(mean(LL{t}, 1));
            h1(t) = plot(n, L(1:nmax), learn_opt{t}.color, 'linewidth', 2);
            
            subplot(1, 2, 2)
            hold on
            time = squeeze(mean(T{t}, 1));
            h2(t) = plot(n, time(1:nmax), learn_opt{t}.color, 'linewidth', 2);
            leg{t} = learn_opt{t}.name;
        end
        
        subplot(1, 2, 1)
        xlabel('number of samples', 'fontsize', 14);
        ylabel('log-likelihood on heldout data', 'fontsize', 14);
        legend(h1, leg, 'fontsize', 12, 'location', 'Best');
        title(sprintf('Error, mean of %d bnets, %d reps', rp.num_bnet, rp.num_nrep));
        
        subplot(1, 2, 2);
        xlabel('number of samples', 'fontsize', 14);
        ylabel('run time (sec)', 'fontsize', 14)
        legend(h2, leg, 'fontsize', 12, 'location', 'Best');
        title('Runtime (sec)', 'fontsize', 14); 
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [rp, learn_opt, D, LL, T, G] = init(in)
    [rp, learn_opt] = init_bn_learn(in);
    [D, LL, T, G] = init_real(in.data, learn_opt, rp);
    assert(in.folds <= 10);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [D, LL, T, G] = init_real(data, learn_opt, rp)
    % load data
    DD = load(sprintf('data/real/mats/%s.mat', data), 'D');
    D = DD.D;
    for i = 1:10
        [D{i}.train, mu, sigma] = normalize_data((D{i}.train)');
        D{i}.test = normalize_data((D{i}.test)', false, mu, sigma);
    end
    nvars = size(D{1}.train, 1);
    
    % initialize LL and T
    LL = cell(length(learn_opt), 1);
    T = cell(length(learn_opt), 1);
    G = cell(length(learn_opt), rp.folds, length(rp.nvec));
    for c = 1:length(learn_opt)
        LL{c} = NaN*ones(rp.folds, length(rp.nvec));
        T{c} = NaN*ones(rp.folds, length(rp.nvec));
        for fold = 1:rp.folds
           for ni = 1:length(rp.nvec)
              G{c, fold, ni} = NaN*zeros(nvars); 
           end
        end
    end
end
