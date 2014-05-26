Sparsity Boost
==============

TODO
- Generalize distp
- Take out unnecessary multiplications by H in kci classifier, since H is idempotent, hence Tr(HAH HBH) = Tr(AHBH).
- Get tests working for compute edge scores and add edge scores.
- Take out unnecessary calculations in computing KCI p-value when performing unconditional test.
- Remove print statements from c++ code.
- Improve discretization- use method which maximizes mutual information.
- Regenerate ROC curves with outliers removed.
- Take another look at test-compute-roc-curves- why is the discrete data performing better?  Doesn't make sense to me.

DATASETS
- T-cell (downloaded, preprocessed)
- Wine
- Dow Jones
- Could talke with Rich Bonneau to get other datasets.
- Also Johnathan Carr.  Should read his paper in Cell.
- Make sure there's nothing in DREAM that I could use.

BASELINES
Compare against other nonlinear, continuous methods.  State of the art in:
- Copula BNs.  Gal Elidan's lightning speed code.
- KDE- Maybe Bach/Jordan 2002.  But there has to be something more recent.
- Nonlinear regression.  Not sure which one to use.

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
