function [AUC, FPrate, TPrate, thresholds] = cROC(confidence, testClass)

% break ties in scores
S = rand('state');
rand('state',0);
confidence = confidence + rand(size(confidence))*10^(-10);
rand('state',S)
[thresholds order] = sort(confidence,1, 'descend');
testClass = testClass(order);

%%% -- calculate TP/FP rates and totals -- %%%
AUC = 0;
faCnt = 0;
tpCnt = 0;
falseAlarms = zeros(1,size(thresholds,2));
detections = zeros(1,size(thresholds,2));
fPrev = -inf;
faPrev = 0;
tpPrev = 0;

P = max(size(find(testClass==1)));
N = max(size(find(testClass==0)));

for i=1:length(thresholds)
    if thresholds(i) ~= fPrev
        falseAlarms(i) = faCnt;
        detections(i) = tpCnt;

        AUC = AUC + polyarea([faPrev faPrev faCnt/N faCnt/N],[0 tpPrev tpCnt/P 0]);

        fPrev = thresholds(i);
        faPrev = faCnt/N;
        tpPrev = tpCnt/P;
    end
    
    if testClass(i) == 1
        tpCnt = tpCnt + 1;
    else
        faCnt = faCnt + 1;
    end
end

AUC = AUC + polyarea([faPrev faPrev 1 1],[0 tpPrev 1 0]);

FPrate = falseAlarms/N;
TPrate = detections/P;
