function [uSamples counts] = uniqueDagSamples(samples)
% samples: a cell list of DAGs (ie. adjacency matrices of same size)
% useful for mcmc post-processing

uSamples = {};
counts = [];

for si=1:length(samples)
	isExist = false;
	for ui=1:length(uSamples)
		if all( samples{si} == uSamples{ui} ), 
			isExist = true; 
			break;
		end
	end
	
	if isExist
		counts(ui) = counts(ui) + 1;
	else
		uSamples{length(uSamples)+1} = samples{si};
		counts(length(counts)+1) = 1;
	end
end

