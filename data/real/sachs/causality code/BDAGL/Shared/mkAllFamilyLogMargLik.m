function allFamilyLogMargLik = mkAllFamilyLogMargLik( data, varargin )
% compute the (log) marginal likelihood of all *possible* families of bayes
% net.
% output, allFamilyLogMargLik, is a #nodes x 2^#nodes matrix
% element row i, column j represents node i having parents bitget(j-1,1:#nodes)
% so, j is a *bit mask* 
% ie, j=1 (=> j-1=0) means i has no parents
%     j=5 means i has nodes 1 and 3 as parents
%
% mandatory arguments:
%  data - #nodes x #data_cases
% 
% optional arguments: (provided as key-value pairs)
%  cpdType: Node model {'multinomial','gaussian'}
%  nodeArity: Number of values each node can take on (applicable only for
%             multinomial case). **data for node i must be in range 1..nodeArity(i)**
%  clampedMask: array of same size as data specifying if node i in
%               data_case j was intervened on.
% 
%  maxFanIn: maximum fan in (ie. num of parents) for all (single value) or each
%            node (#nodes x 1 vector of values).
%            can also be specified as a #layers x #layers (see
%            nodeLayering) upper triangular matrix. diagonal is max fan in
%            from *all* other layers, whereas above the diagonal is max fan
%            in from layer i. 
%  nodeLayering: integer labels specifying which "layer" of the bayes net
%                the corresponding node belongs to. higher layers cannot be
%                parents of lower layers. ex: 3 nodes, nodeLayering = [1 2 2]
%                means n1 is in layer 1, and n2 & n3 are in layer 2. n1
%                can be the parent of n2 or n3, but not the other way around.
%                is specified as #nodes x 1 vector.
%  impossibleFamilyMask: a #nodes x 2^#nodes matrix specifying which
%                        elements of the allFamilyLogMargLik represent impossible
%                        configurations. can be provided instead of
%                        maxFanIn/nodeLayering. a 0 means that the specific
%                        family configuration is impossible and therefore
%                        the log marg lik need not be computed there.
%
%  interventionType: {'perfect', 'imperfect', 'soft', 'uncertainPerfect'}
%                    perfect: cooper & yoo, 1999
%                    imperfect: tian & pearl, 2001
%                    soft: markowetz et al. 2005
%                    uncertainPerfect: experimental
%  softPushStrength: "strength" of the soft intervention
%  softPushTarget: target value of the soft intervention
%                   same size as clamped, '0' means that
%
%  uncertainNodes: for uncertainPerfect interventions 
%                  note, doesn't make sense for a  node to have 2 perfect uncertain intervention parents
%                  that are both on *simultaneously*
%
%  priorESS: "strength" of dirichlet parameter prior (usually denoted \alpha)

[clampedMask, cpdType, nodeArity, ...
	maxFanIn, nodeLayering, impossibleFamilyMask, ...
	interventionType, softPushStrength, softTarget, verbose, priorESS, ...
    uncertainNodes ] = process_options(varargin, 'clampedMask', zeros(size(data)), ...
	'cpdType', 'multinomial', 'nodeArity', [], ...
	'maxFanIn', [], 'nodeLayering', [], 'impossibleFamilyMask', [],  ...
	'interventionType', 'perfect', 'softPushStrength', [], 'softTarget', [], 'verbose', 0, ...
    'priorESS', 1, 'uncertainNodes', [] );

nNodes = size(data,1);

if strcmp(cpdType, 'multinomial') && isempty(nodeArity)
	error('For Multinomial CPDs, you must specify the node arity');
end

if size(nodeArity,1) > size(nodeArity, 2)
	nodeArity = nodeArity';
end

if strcmp(cpdType, 'multinomial') && any(nodeArity==1)
	error('Unary variables are not allowed');
end

if isempty(impossibleFamilyMask)
	impossibleFamilyMask = mkImpossibleFamilyMask( nNodes, maxFanIn, nodeLayering );
end

intervention.type = interventionType;
intervention.softPushStrength = softPushStrength;
intervention.softTarget = softTarget;
intervention.clampedMask = clampedMask;

if strcmp(intervention.type,'uncertainPerfect') && isempty(uncertainNodes)
    error('To use uncertain perfect interventions, `uncertainNodes'' most be specified');
end

intervention.uncertainNodes = uncertainNodes;

if strcmp(intervention.type, 'soft')
    if isempty(softTarget) || isempty(softPushStrength)
        error('For soft interventions, softTarget and softPushStrength must be provided');
    end
end

switch cpdType
	case 'multinomial'
		allFamilyLogMargLik = logMargLikMultiFamilyAll(data, nodeArity, impossibleFamilyMask, priorESS, intervention, verbose );
	case 'gaussian'
		allFamilyLogMargLik = logMargLikGaussFamilyAll(data, impossibleFamilyMask, intervention, verbose );
	otherwise
		error('Unhandled CPD type: %s', cpdType);
end

