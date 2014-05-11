function [logPrior isCyclic]= uniformGraphLogPrior( dag )

isCyclic = ~acyclic(dag);
if isCyclic
	logPrior = -Inf;
else
	logPrior = log(1);
end
