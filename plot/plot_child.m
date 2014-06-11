
load child_my_one
nvec = in.nvec;

figure
hold on

for i = 1:length(learn_opt)
   s = reshape(SHD{i}, [in.num_bnet*in.num_nrep length(nvec)]);
   h(i) = errorbar(nvec, mean(s), std(s), learn_opt{i}.color, 'linewidth', 2);
   names{i} = learn_opt{i}.name;
end

xlabel('number of samples (n)', 'fontsize', 14);
ylabel('structural hamming distance', 'fontsize', 14);
title('Child network, synthetic quadratic gaussian data, 3 parameter settings, 3 reps', 'fontsize', 16);
legend(h, names);