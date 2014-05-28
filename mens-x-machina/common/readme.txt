-----------------------------------
Mens X Machina Common Toolbox 0.9.3
-----------------------------------

Mens X Machina Common Toolbox is a toolbox with common packages used by other toolboxes provided by Mens X Machina.

Toolbox website: http://www.mensxmachina.org/common-toolbox

------------
Requirements
------------

- MATLAB¨ R2011b or later
- MATLAB Statistics Toolbox“
- MATLAB Bioinformatics Toolbox“
- MATLAB Neural Network Toolbox“ (for some functions)
- MATLAB xUnit Test Framework in order to run the unit sets. Downloadable from http://www.mathworks.com/matlabcentral/fileexchange/22846-matlab-xunit-test-framework

------------
Installation
------------

To use Common Toolbox in MATLAB, add the "common/common" directory to the MATLAB path. See the MATLAB documentation for setting the search path. The "common/tests" directory contains MATLAB xUnit tests. xUnit must be on the MATLAB path in order to run the tests.

--------
Packages
--------

- org.mensxmachina.classification.performance			Classification performance
- org.mensxmachina.array					Array manipulation
- org.mensxmachina.graph					Graph manipulation
- org.mensxmachina.graph.biograph				Biograph manipulation
- org.mensxmachina.stats.cpd					Conditional probability distributions
- org.mensxmachina.stats.cpd.inference				Probabilistic inference
- org.mensxmachina.stats.lg					Linear-Gaussian conditional probability distributions
- org.mensxmachina.stats.tabular				Tabular conditional probability distributions
- org.mensxmachina.stats.array					Statistical-array manipulation
- org.mensxmachina.stats.array.io.latex				LaTeX I/O for statistical arrays
- org.mensxmachina.stats.mt.error				Multiple-testing-error estimation
- org.mensxmachina.stats.mt.error.fdr				false-discovery-rate estimation
- org.mensxmachina.stats.mt.error.fdr.by2001			Benjamini and Yekutieli (2001) false-discovery-rate estimation
- org.mensxmachina.stats.mt.error.fdr.lambda			Lambda false-discovery-rate estimation
- org.mensxmachina.stats.mt.error.fdr.lambda.st2001		Storey and Tibshirani (2001) false-discovery-rate estimation
- org.mensxmachina.stats.mt.error.fdr.lambda.storey2002		Storey (2002) false-discovery-rate estimation
- org.mensxmachina.stats.mt.error.fdr.lambda.sts2004		Storey, Taylor and Siegmund (2004) false-discovery-rate estimation
- org.mensxmachina.stats.mt.mtp					Multiple-testing procedures
- org.mensxmachina.stats.mt.mtp.error				Error-estimating multiple-testing procedure
- org.mensxmachina.stats.mt.stats.tests.ci			Hypothesis tests of conditional independence
- org.mensxmachina.stats.mt.stats.tests.ci.chi2			Chi-square tests of conditional independence
- org.mensxmachina.stats.mt.stats.tests.ci.chi2.heuristic	Heuristic power rule (conditional-independence-test reliability criterion)
- org.mensxmachina.stats.mt.stats.tests.ci.chi2.power		POWER correction (conditional-independence-test reliability criterion)
- org.mensxmachina.stats.mt.stats.tests.ci.chi2.thumb		Rule of thumb (conditional-independence-test reliability criterion)
- org.mensxmachina.stats.mt.stats.tests.fishersz		Fisher's Z test of conditional independence
- org.mensxmachina.stats.mt.stats.tests.ci.utils		Conditional-independence-test utilities
- org.mensxmachina.string					String manipulation

-------
Contact
-------
For any question, suggestion or bug report please contact Angelos P. Armen: angelos.armen@gmail.com

Copyright © 2010-2012 Mens X Machina - http://www.mensxmachina.org