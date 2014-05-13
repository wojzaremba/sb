Sparsity Boost
==============

TODO
- In computing distribution over p-values, first take out guys that are confident about dependence.  Then estimate f0.  Then put the other guys back in and estimate f1 and p0.  It seems that p0 has an upper limit, since only so much of the distribution is concentrated near 0.
- Look at previous work using kernels to learn BNs
- Devise scoring function for KCI
- Generalize distp
- Take out unnecessary multiplications by H in kci_classifier, since H is idempotent, hence Tr(HAH HBH) = Tr(AHBH).
- Get tests working for compute_edge_scores and add_edge_scores.
- Take out unnecessary calculations in computing KCI p-value when performing unconditional test.


POSSIBLE DIRECTIONS
DEPENDENCY MODEL:
1) empirical prior: mixture model marginalizing over all pairs in data (or only pairs deemed marginally dependent by some independence test)
2) Fit a MLE of minimally dependent distribution matching data marginals.  Sample from this, estimate p-value giving confidence of dependence.  I am thinking copulas are the most promising direction.  Would like to have consistency between the estimation/assumptions used by the independence term as for the dependence term.  In other words, if I use copulas to estimate independence, would like to use copulas also to compute the likelihood. 
3) As an alternative to 1), maybe we don't need to use density estimates in order to compute a p-value for dependence.  For example, we could just compute the statistic (e.g. KCI rho) for each of the distributions marginalized, and then maybe resample to estimate this distribution over rho.  

LIKELIHOOD:
- Kernel Conditional Density Estimation 

CONSTRAINT-BASED APPROACHES
- Look more into Strimmer 2007, constructing partial correlation graph.
- David suggested just sorting the results of all pairs independence results, and then based on some prior over the sparsity of your graph, choose some threshold.

HYBRID APPROACHES
- Maybe we could do something like Strimmer 2007, but use this to incorporate constraints about independence into a score. 

Setting up hooks
================
If you would like to submit anything, please setup testing hooks on your machine.

    cd .git/hooks
    .git/hooks$ ln -s ../../PRESUBMIT.py pre-commit
    chmod a+x ./pre-commit
