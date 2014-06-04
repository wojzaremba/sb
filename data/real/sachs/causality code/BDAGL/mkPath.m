

addpath('Shared');
addpath('StructureMcmc');
addpath('DP');
addpath('OrderMcmc');
addpath('ExactEnumeration');
addpath('DagHashTable');
addpath('ADTree');
%addpath('DagGibbs');
%addpath('Foreign/ChowLiu');
%addpath('TestData');
addpath('DBN');
%addpath('Demos');
addpath('demos2');
addpath('OptimalMAP');
addpath('Foreign/causalExplorer/');
addpath('Foreign/causalExplorer/PCodes/');
addpath('Foreign');
addpath('Mex');

mkMex('Mex');
mkMex('DagHashTable');
mkMex('DP');
mkMex('OrderMcmc');

if exist('gammaln')~=3
	cd('Foreign');
	mex -O gammaln.c minka_mexutil.c minka_util.c
	cd('..');
end 

cd('ADTree');
if  exist('mkADTree')~=3
	mex -O mkADTree.c util.c
end
if  exist('mkContab')~=3
	mex -O mkContab.c
end
if  exist('testADTree')~=3
	mex -O testADTree.c
end
if  exist('maxNumADTrees')~=3
	mex -O maxNumADTrees.c
end
cd('..');

