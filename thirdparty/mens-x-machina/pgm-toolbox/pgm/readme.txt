----------------------------------------------------------
Mens X Machina Probabilistic Graphical Model Toolbox 0.9.3
----------------------------------------------------------

Mens X Machina Probabilistic Graphical Model Toolbox (PGM Toolbox) aims to provide a comprehensive set of tools for Bayesian networks and other probabilistic graphical models.

Toolbox website: http://www.mensxmachina.org/pgm-toolbox

------------
Requirements
------------

- MATLAB¨ R2011b or later
- MATLAB Statistics Toolbox“
- MATLAB Bioinformatics Toolbox“
- MATLAB Neural Network Toolbox“ (for some demos)
- Mens X Machina Common Toolbox 0.9.3. Downloadable from http://www.mensxmachina.org/common-toolbox/
- MATLAB xUnit Test Framework in order to run the unit sets. Downloadable from http://www.mathworks.com/matlabcentral/fileexchange/22846-matlab-xunit-test-framework

------------
Installation
------------

To use PGM Toolbox in MATLAB, add the "pgm/pgm" directory to the MATLAB path. See the MATLAB documentation for setting the search path. The "pgm/tests" directory contains MATLAB xUnit tests. xUnit must be on the MATLAB path in order to run the tests.

--------
Packages
--------

- org.mensxmachina.pgm.bn 					Bayesian networks
- org.mensxmachina.pgm.bn.converters.dsl 			Bayesian-network conversion to/from Discovery Systems Laboratory format
- org.mensxmachina.pgm.bn.demos 				Bayesian-network demos
- org.mensxmachina.pgm.bn.inference.demos 			Bayesian-network inference demos
- org.mensxmachina.pgm.bn.inference.jtree 			Junction-tree Bayesian-network inference
- org.mensxmachina.pgm.bn.io.bif 				BIF file I/O
- org.mensxmachina.pgm.bn.io.hugin 				HUGIN file I/O
- org.mensxmachina.pgm.bn.io.xdsl 				XDSL file I/O
- org.mensxmachina.pgm.bn.learning.cb 				Constraint-based learning
- org.mensxmachina.pgm.bn.learning.cb.cit 			Constraint-based learning with conditional-independence tests
- org.mensxmachina.pgm.bn.learning.cb.cit.dag 			Constraint-based learning with directed-acyclic-graph-based conditional-independence test
- org.mensxmachina.pgm.bn.learning.cb.dag 			Constraint-based learning with directed acyclic graph
- org.mensxmachina.pgm.bn.learning.cb.lg 			Local-to-global learning (LGL)
- org.mensxmachina.pgm.bn.learning.cb.lg.gl 			Generalized local learning (GLL)
- org.mensxmachina.pgm.bn.learning.cb.lg.gl.mm 			Min-max local-to-global learning (MMPC and MMPC-skeleton algorithms)
- org.mensxmachina.pgm.bn.learning.cb.lg.gl.mm.cit 		Min-max local-to-global learning with conditional-independence tests
- org.mensxmachina.pgm.bn.learning.cb.lg.gl.mm.dag 		Min-max local-to-global learning with directed acyclic graph
- org.mensxmachina.pgm.bn.learning.cpd 				Bayesian-network-parameter learning
- org.mensxmachina.pgm.bn.learning.cpd.bdeu 			Bayesian-network-BDeu-parameter learning
- org.mensxmachina.pgm.bn.learning.demos 			Bayesian-network-learning demos
- org.mensxmachina.pgm.bn.learning.pc 				Bayesian-network-node-parents-and-children learning
- org.mensxmachina.pgm.bn.learning.skeleton 			Bayesian-network-skeleton learning
- org.mensxmachina.pgm.bn.learning.skeleton.cb.pc 		PC algorithm
- org.mensxmachina.pgm.bn.learning.skeleton.cb.pc.mt 		Multiple-testing PC algorithm
- org.mensxmachina.pgm.bn.learning.structure 			Bayesian-network-structure learning
- org.mensxmachina.pgm.bn.learning.structure.sns.local 		Bayesian-network-structure learning with search-and-score methods with local scoring 
- org.mensxmachina.pgm.bn.learning.structure.sns.local.bdeu 	Bayesian-network-structure learning with search-and-score methods with local BDeu scoring 
- org.mensxmachina.pgm.bn.learning.structure.sns.local.hc 	Bayesian-network-structure learning with local-scoring hill climbing
- org.mensxmachina.pgm.bn.tabular				Bayesian networks with tabular conditional probability distributions
- org.mensxmachina.pgm.bn.viewers				Bayesian-network viewers
- org.mensxmachina.pgm.bn.viewers.biograph			Biograph-based Bayesian-network viewers

------------
Data sources
------------

The accompanying Insurance and Pigs Bayesian networks have been read from a BIF and a HUGIN file, respectively, downloaded from the Bayesian Network Repository: 

http://www.cs.huji.ac.il/~galel/Repository/

The accompanying Alarm, Andes, Barley, Diabetes, Hailfinder, Hepar II, Link, Munin, Win95pts, Mildew, Water and Power Plant Bayesian networks have been read from XDSL files downloaded from the GeNIe & SMILE Network Repository:

http://genie.sis.pitt.edu/networks.html

-------
Contact
-------
For any question, suggestion or bug report please contact Angelos P. Armen: angelos.armen@gmail.com

Copyright © 2010-2012 Mens X Machina - http://www.mensxmachina.org