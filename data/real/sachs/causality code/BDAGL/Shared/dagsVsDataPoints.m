% load some data sampled from a randomly generated 4-var bnet
%load('dagsVsDataPointsSampleData');
load('dagsVsDataPointsSampleData2'); 

dags = mkAllDags(4,3); % vertical axis
subs = ind2subv( bnet.node_sizes, 1:prod(bnet.node_sizes) ); % horizontal axis

testDataHisto = dataToHistogram(dataTest, nodeArities);
testDataHisto = testDataHisto /sum(testDataHisto);
figure(1); clf; bar(testDataHisto);
set(gca, 'xlim', [0 82]);

exactHisto = bnetToHistogram(bnet);
figure(2); clf; bar(exactHisto);
set(gca, 'xlim', [0 82]);

aflmlTrain = mkAllFamilyLogMargLik( dataTrain, 'nodeArity', nodeArities, 'impossibleFamilyMask', aflp~=-Inf);
aflmlTest = mkAllFamilyLogMargLik( dataTest, 'nodeArity', nodeArities, 'impossibleFamilyMask', aflp~=-Inf);

ADTreePtrTrain = mkADTree(dataTrain', nodeArities, 3);

dagMargLik = zeros(length(dags), 1); % p(M|D)
for di=1:length(dags)
    dagMargLik(di) = logMargLikDag(char2dag(dags(di,:), nNodes), aflmlTrain );
end
dagMargLik = dagMargLik - logsumexp(dagMargLik);
dagMargLik = exp(dagMargLik);
figure(4); clf; barh(-(1:length(dags)), -dagMargLik);
set(gca, 'ylim', [-544 0]);

logPredLikDagsStates = zeros(length(dags), size(subs,1));
for di=1:length(dags)
    dag = char2dag(dags(di,:), nNodes);
    params = posteriorMeanParams(dag, nodeArities, ADTreePtrTrain);
    for si=1:size(subs,1)
        logPredLikDagsStates(di,si) = logPredLikDag( dag, params, nodeArities, subs(si,:)' );
    end
end

figure(3); clf; imagesc(exp(logPredLikDagsStates));
set(gca, 'xlim', [0 82]);
set(gca, 'ylim', [0 544]);
axis('tight');

score = repmat(dagMargLik, 1, size(subs,1)) .* exp(logPredLikDagsStates);
figure(5); clf; imagesc( score );
set(gca, 'xlim', [0 82]);
set(gca, 'ylim', [0 544]);
axis('tight');

figure(6); clf; 
bar( sum(score, 1) );
set(gca, 'xlim', [0 82]);

