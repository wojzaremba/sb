function lpl = logPredLikDagsMultiple( dags, logWeights, nodeArities, ADTreePtrTrain, testData, testClamped )
% dags is a cell list of dags
% logWeights are the log weights of each dag (length same as dags, should sum to 1 after taking exponential)

if nargin<5
    testClamped = zeros(size(data));
end

lpl = 0;

logWeights = logWeights - logadd_sum(logWeights);

% pre-compute parameters
params = {};
for gi=1:length(dags)
    params{gi} = posteriorMeanParams( dags{gi}, nodeArities, ADTreePtrTrain );
end

for ti=1:size(testData,2)
   
    testPoint = testData(:,ti);
    
    logPredLikSingleModelSinglePoint = zeros(1,length(dags));
    for gi=1:length(dags)
        logPredLikSingleModelSinglePoint(gi) = logPredLikDag( dags{gi}, params{gi}, nodeArities, testPoint, testClamped(:,ti) );
    end
    
    logPredLikSinglePoint = logsumexp( logWeights + logPredLikSingleModelSinglePoint );
    
    lpl = lpl + logPredLikSinglePoint;
    
end

lpl = lpl / size(testData,2);