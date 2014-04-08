skips{1} = 10*ones(7,1);
skips{2} = ones(7,1);

load asia_linear_arity_3
plot_roc_multi
clear all

skips{1} = ones(7,1);
skips{2} = ones(7,1);

load asia_linear_arity_5
plot_roc_multi
clear all

skips{1} = ones(7,1);
skips{2} = ones(7,1);

load asia_random_arity_3
plot_roc_multi
clear all

skips{1} = ones(7,1);
skips{2} = ones(7,1);

load asia_random_arity_5
plot_roc_multi
clear all