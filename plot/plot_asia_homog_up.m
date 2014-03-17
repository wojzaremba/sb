function [CPD,bnet] = plot_asia_homog_up();

bnet = mk_asia_homog_up_bnet();
CPD = gen_cpd_dist(bnet);
plot_cpd(CPD);