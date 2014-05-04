dep = {};
indep = {};
all = {};
data_cts = {};

for i = 1:2
    [dep{i}, indep{i}, all{i}, data_cts{i}] = learn_dependence();
end