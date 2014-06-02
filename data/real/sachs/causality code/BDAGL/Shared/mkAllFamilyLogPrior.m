function rho = mkAllFamilyLogPrior(nNodes, varargin)
% maxFanIn 
% set rho(i,Gi) = 1/ nchoosek(N-1, |Gi|) or 0 if Gi contains i or is bigger than maxFanIn

[maxFanIn, layer, priorType, doSparse] = process_options(varargin, 'maxFanIn', nNodes-1, ...
    'nodeLayering', ones(nNodes,1), 'priorType', 'nchoosek', 'doSparse', false);

impossibleFamilyMask = mkImpossibleFamilyMask(nNodes, maxFanIn, layer);

if doSparse
    rho = sparse( nNodes, 2^nNodes );
else
    rho = repmat(-Inf, nNodes, 2^nNodes);
end

logNchoosekPre = zeros(1, max(maxFanIn(:))+1 );
for k=0:max(maxFanIn(:))
    logNchoosekPre(k+1) = log(1/nchoosek(nNodes-1, k));
end

for ni=1:nNodes
    possibleFamilies = impossibleFamilyMask(ni,:);
    switch(priorType)
        case 'nchoosek'
            for ui=find(possibleFamilies)
                sz = sum( bitget(ui-1, 1:nNodes) );
%                rho(ni, ui) = log(1/nchoosek(nNodes-1, sz)); % JMLR p554
                rho(ni, ui) = logNchoosekPre(sz+1); % JMLR p554
            end
        case 'flat'
            rho(ni, possibleFamilies) = log(1);
        otherwise
            error('Unknown family prior type: %s', priorType);
    end
end