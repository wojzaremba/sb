Sparsity Boost
==============

TODO
- Look at previous work using kernels to learn BNs
- Devise scoring function for KCI
- Generalize distp
- Take out unnecessary multiplications by H in kci_classifier, since H is idempotent, hence Tr(HAH HBH) = Tr(AHBH).
- Get tests working for compute_edge_scores and add_edge_scores.
- Test learn_mrf.

Setting up hooks
================
If you would like to submit anything, please setup testing hooks on your machine.

    cd .git/hooks
    .git/hooks$ ln -s ../../PRESUBMIT.py pre-commit
    chmod a+x ./pre-commit
