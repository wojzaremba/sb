function ml = logMargLikDagSlow( dag, data, nodeArity, varargin )
% compute the log marginal likelihood of a given dag
% use mkAllFamilyLogMargLik to compute the logMargLik

% only works for multinomial nodes now

[clampedMask, ...
	maxFanIn, nodeLayering, ...
	interventionType, softPushStrength, softTarget, priorESS ] = process_options(varargin, 'clampedMask', zeros(size(data)), ...
	'maxFanIn', [], 'nodeLayering', [], 'interventionType', 'perfect', 'softPushStrength', [], 'softTarget', [], 'priorESS', 1 );

nNodes = size(data,1);

intervention.type = interventionType;
intervention.softPushStrength = softPushStrength;
intervention.softTarget = softTarget;
intervention.clampedMask = clampedMask;

if strcmp(intervention.type, 'soft')
    if isempty(softTarget) || isempty(softPushStrength)
        error('For soft interventions, softTarget and softPushStrength must be provided');
    end
end

if size(nodeArity,1) > size(nodeArity, 2)
	nodeArity = nodeArity';
end

ml = 0;
for ni=1:length(dag)
    
	pa = find(dag(:,ni))';
	
    if( ~isValidFamily( ni, pa, maxFanIn, nodeLayering ) )
        tml = -Inf;
    else
        unclampedData = data(:, clampedMask(ni,:)==0 );
        clampedData = data(:, clampedMask(ni,:)==1 );
	
        tml = logMargLikMultiFamilySlow( unclampedData, clampedData, pa, ni, nodeArity, priorESS, intervention );
    end
    
    ml = ml + tml;
    
end