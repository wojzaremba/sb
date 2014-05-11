function out = transformDbnData(data, varargin)

% make dbn input suitable for use with koivisto's algorithm
% for now, only handle order 1 DBNs (ie. interactions only between t and t-1
% ie. enable koivisto to handle dbns

% arguments:
%    data: #nodes x #time_steps
%
% optional arguments: (key-value)
%    clampedMask: #nodes x #time_steps
%    maxFanIn: maxium in-degree of any node (scalar), otherwise assumed to
%              be nNodes*2-1
%
% Note: nothing can be learned from a single datapoint. Therefore, there is
% no point in trying to learn the structure of the special case at time=0.

nNodes = size(data,1);
nTs = size(data,2);

[clampedMask maxFanIn] = process_options(varargin, 'clampedMask', [], 'maxFanIn', 2*nNodes-1 );

out.data = zeros(nNodes*2, nTs-1);
out.data( 1:nNodes, : ) = data(:, 1:end-1);
out.data( nNodes+1:end, : ) = data(:, 2:end);

if ~isempty(clampedMask)
   
    out.clampedMask = zeros(nNodes*2, nTs-1);
    out.clampedMask( 1:nNodes, : ) = clampedMask(:, 1:end-1);
    out.clampedMask( nNodes+1:end, : ) = clampedMask(:, 2:end);
    
end

out.nNodes = nNodes*2;
out.nodeLayering = [ones(1,nNodes) 2*ones(1,nNodes)];

% the first (past) layer cannot have any parents, else we would be learning
% the intraslice structure in both slices independently.
out.maxFanIn = [0 -1 ; ...
                0 maxFanIn ];