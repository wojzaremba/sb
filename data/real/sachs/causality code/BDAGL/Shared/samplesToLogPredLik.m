function mlogPredLik = samplesToLogPredLik(samples, nodeArity, ADTreePtr_train, testData )
% convert the output of sampleDags*.m to edge marginals

count = samples.nSamples;

nTestPoints = size(testData,2);

score = 0;
for ti=1:nTestPoints
    
    keys = samples.HT.keys;

    testPoint = testData(:,ti);
    
    tscore = -Inf;
    j=0;
    while keys.hasMoreElements()
        dagKey = keys.nextElement();
        dagVal = samples.HT.get(dagKey);

        dag = char2dag(dagKey, samples.nNodes);

        weight = dagVal(1)/count; % q(M|D)
        
        j=j+1;
        tscore(j) = log(weight) + logPredLikDag(dag, posteriorMeanParams(dag, nodeArity, ADTreePtr_train), nodeArity, testPoint );
        
    end
    
    score = score + logsumexp(tscore);

end

score = score / nTestPoints;
mlogPredLik = score;   
