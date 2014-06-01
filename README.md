Sparsity Boost
==============

TODO
- Consider caching Tr(Ky(:)).  Then, if I don't use the pvalues, I can use the that H is idempotent to compute Tr(HAH HBH) = Tr(AHBH), i.e. I only need to compute KxH, etc. 
- Take out unnecessary calculations in computing KCI p-value when performing unconditional test.
- Remove print statements from c++ code.
- Improve discretization- use method which maximizes mutual information.
- Regenerate ROC curves with outliers removed.
- Consider learning network multiple times in order to improve edge classifier. 
- Need to prove that the edge classifier is consistent.  The problem I need to make sure won't happen is that the dependent distribution doesn't look like a sharp peak and yet really have a segmeent hiding in the flat part of the distribution.
- Evaluate the AUC of the Bayes edge classifier.
- Remember to mention Joris Mooij paper, emphasize that I am using only observational data, maybe discuss how to incorporate interventional data into our approach.
- Reiterate in the paper that minimizing the pseudo-likelihood term is exactly equivalent to maximizing the likelihood, under the assumption that the data are drawn from y ~ A phi(x) + eps.
- Plot edge scores' beta function.

SCALING
- Tried dividing norm(K(:)) by total mean, mean of each conditioning set size, n, sqrt(n), log(n).  sqrt(n) seemed to do the best, but still didn't seem to be converging.

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

CONSTRAINT-BASED APPROACHES
- Look more into Strimmer 2007, constructing partial correlation graph.
- David suggested just sorting the results of all pairs independence results, and then based on some prior over the sparsity of your graph, choose some threshold.

HYBRID APPROACHES
- Maybe we could do something like Strimmer 2007, but use this to incorporate constraints about independence into a score. 

THE STORY

The story is we have a new scoring function.  The first term is equivalent to a log-likelihood term, under a linear data model with Gaussian noise in RKHS.  The second term is a data-dependent regularization term based on conditional independence tests.  Our score uses the framework presented in (UAI 13 SB) paper, however whereas the original implementation only applied to binary variables, the score presented here applies to discrete variables with arbitrary numbers of states as well as continuous variables.  We make use of a kernelized conditional independence test presented by Zhang et al 2012. 
Setting up hooks
================
If you would like to submit anything, please setup testing hooks on your machine.

    cd .git/hooks
    .git/hooks$ ln -s ../../PRESUBMIT.py pre-commit
    chmod a+x ./pre-commit

Configuration
=============
You need to create a file in the config directory called config.txt.  It should contain the following lines:
GOB=foo/bar/gobnilp/bin/gobnilp
MAXPOOL=numworkers

Maxpool is the number of cores available for parallel processing in MATLAB.  You can check this in matlab by typing parpool(100) and it will say this is too much and will tell you the correct number. 
