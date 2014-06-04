function [data clamped] = mkData(bnet, nObservationCases, interventions, nInterventionCases )
% sample data from a given a bayes net (BNT)
% optionally add intervention cases
%
% nObservationCases: number of purely observational data to sample
% interventions: a cell array of interventions to be performed. each entry
%           of the array is itself a cell array denoting the interventions (assignments) for that case.
%           [] denotes an observed node (ie. non-interventional).
%           ie. for a 3 node network, { {2, [], []}, {[], 1, -1} } means there are two types of
%           intervention. in the first case, node 1 is set to the value 2 and the other nodes are just
%           observed. in the second case, node 1 is just observed, node 2 is set to the value 1, and node
%           3 has a a value chosen for it uniformly at random (from 1..M where M is the node arity)
% nInterventionCases: number of interventional cases to sample -- if there
%           is more than one type of intervention, an equal number of each type is
%           sampled such that the total number of intervnetional cases is nInterventionCases

if nargin<3
    interventions = {};
    nInterventionCases = 0;
end

observationData = zeros( length(bnet.dag), nObservationCases );
observationClamped = zeros( size(observationData) );

for m = 1:nObservationCases
	samp = sample_bnet(bnet);
	observationData(:,m) = cell2num(samp);
end

interventionData = zeros( length(bnet.dag), nInterventionCases );
interventionClamped = zeros( size(interventionData) );

nInterventions = length(interventions);
if nInterventionCases > 0
	partition = round((1/nInterventions:1/nInterventions:1)*nInterventionCases);
	j = 1;
	for m = 1:nInterventionCases
		if m > partition(j)
			j = j+1;
		end

		intervention = interventions{j};
		for i=1:length(intervention)
			if intervention{i} == -1, intervention{i} = ceil(rand*bnet.node_sizes(i)); end
			if ~isempty(intervention{i}), interventionClamped(i,m) = 1; end
		end

		samp = sample_bnet(bnet, 'evidence', intervention);
		interventionData(:,m) = cell2num(samp);
	end
end

data = [ observationData interventionData ];
clamped = [ observationClamped interventionClamped ];