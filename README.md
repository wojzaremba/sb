Sparsity Boost
==============

TODO
- FIX ROC and PRECISION CURVES !!!
- Look at previous work using kernels to learn BNs
- Devise scoring function for KCI
- Look into conditioning on many nodes.
- Generalize distp
- Download proper dataset (Karen Sachs? yeast?)
- Take out unnecessary multiplications by H in kci_classifier, since H is idempotent, hence Tr(HAH HBH) = Tr(AHBH).


Setting up hooks
================
If you would like to submit anything, please setup testing hooks on your machine.

    cd .git/hooks
    .git/hooks$ ln -s ../../PRESUBMIT.py pre-commit
    chmod a+x ./pre-commit
