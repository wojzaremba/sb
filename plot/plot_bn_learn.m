function plot_bn_learn(b, r, rp, learn_opt, SHD, T)
clf;
[h1, h2, leg] = deal([], [], {});
for c = 1 : length(learn_opt)
    leg{end+1} = learn_opt{c}.name;
    
    subplot(1, 2, 1); hold on
    ham = SHD{c}(1:b, 1:r, :);
    ham
    h1(end+1) = plot(rp.nvec, squeeze(mean(mean(ham, 1), 2)), ...
        learn_opt{c}.color, 'linewidth', 2);
    
    subplot(1, 2, 2); hold on
    tt = T{c}(1:b, 1:r, :);
    tt
    h2(end+1) = plot(rp.nvec, squeeze(mean(mean(tt, 1), 2)), ...
        learn_opt{c}.color, 'linewidth', 2);
end

subplot(1, 2, 1);
legend(h1, leg);
yl = ylim;
ylim([0 yl(2)]);
xlabel('number of samples');
ylabel('structural hamming distance');
title(sprintf('SHD vs. N, %s network, %d parameter settings, %d reps', ...
    rp.network, b, r), 'fontsize', 14);

subplot(1, 2, 2);
legend(h2, leg);
xlabel('number of samples');
ylabel('runtime (sec)');
title(sprintf('Runtime vs. N, %s network, %d parameter settings, %d reps', ...
    rp.network, b, r), 'fontsize', 14);
pause(2);
end