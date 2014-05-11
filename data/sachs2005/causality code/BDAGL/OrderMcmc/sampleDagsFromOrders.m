function [dagSamples dagDiagnostics] = sampleDagsFromOrders( allFamilyLogScore, orderSamples, orderDiagnostics, varargin )

[ nDagSamplesPerOrder, fixedComputeTime, verbose ] = process_options(varargin, 'nDagSamplesPerOrder', 1, ...
	'fixedComputeTime', Inf, 'verbose', false );

nNodes = size(allFamilyLogScore, 1);

nUniqueOrders = orderSamples.HT.size;
nRequestedSamples = orderSamples.nSamples * nDagSamplesPerOrder;

% generate dag samples in a similar manner as sampleDags or sampleDagsGibbs
dagSamples = [];
dagSamples.nNodes = nNodes;
dagSamples.HT = java.util.Hashtable(2^15);
dagSamples.order = zeros(1, nRequestedSamples);
dagSamples.order2DagHT = java.util.Hashtable(2^15);

dagDiagnostics = [];
dagDiagnostics.timing = zeros(1, nRequestedSamples);

baseTiming = orderDiagnostics.timing(1);
	
nActualSamples = 0;
orderIndex = 0; % other meaning of order
for j=1:length(orderSamples.order)
	
	tic;

	orderKey = orderSamples.order2OrderHT.get( orderSamples.order( j ));
	
	dags = sampleDagsFromOrder( allFamilyLogScore, uint32(orderKey), nDagSamplesPerOrder );
	for di=1:nDagSamplesPerOrder

		nActualSamples = nActualSamples + 1;

		dagKey = dag2char(dags{di});
		dagValue = dagSamples.HT.get(dagKey);
		if isempty(dagValue)
			count = 1;
			ind = orderIndex;
			orderIndex = orderIndex + 1;
			
			% determine how many orders this dag is consistent with
			weight = 0;
			keys = orderSamples.HT.keys;
			while keys.hasMoreElements()
				orderKey2 = keys.nextElement();
				weight = weight + isDagOrderConsistent( dags{di}, uint32(orderKey2) );
			end
			weight = 1/weight;
						
			dagSamples.order2DagHT.put( ind, dagKey );
		else
			count = dagValue(1) + 1;
			ind = dagValue(2);
			weight = dagValue(3);
		end
		dagSamples.order(nActualSamples) = ind;
		dagSamples.HT.put( dagKey, [count ind weight] );

		dagDiagnostics.timing(nActualSamples) = baseTiming + toc;
		
	end
	
	if j<length(orderSamples.order)
		baseTiming = dagDiagnostics.timing(nActualSamples) + (orderDiagnostics.timing(j+1)-orderDiagnostics.timing(j));
	end
	
	if verbose && nActualSamples>0 && mod(nActualSamples,1000)==0
		fprintf('orders -> dags %i (%.2f)\n', nActualSamples, baseTiming);
	end
	
	if baseTiming>fixedComputeTime
		fprintf('fixed amount of time %fs exceeded\n', fixedComputeTime);
		fprintf('%i samples taken\n', nActualSamples);
		break;
	end	
end

dagDiagnostics.timing = dagDiagnostics.timing(1:nActualSamples);
dagSamples.order = dagSamples.order(1:nActualSamples);
dagSamples.nSamples = nActualSamples;
% 
% % find new normalization constant for joint weights and counts (subsequent
% % code just normalizes by count, so 'weight' must be modified to include
% % the joint constant)
% prodSum = 0;
% keys = dagSamples.HT.keys();
% while keys.hasMoreElements()
% 	key = keys.nextElement();
% 	value = dagSamples.HT.get(key);
% 	
% 	prodSum = prodSum + value(1)/dagSamples.nSamples * value(3);
% 	
% end
% 
% keys = dagSamples.HT.keys();
% while keys.hasMoreElements()
% 	key = keys.nextElement();
% 	value = dagSamples.HT.get(key);
% 
% 	value(3) = value(3) / prodSum;
% 	dagSamples.HT.put(key, value);
% 		
% end
% 
% % check: newps should equal 1
% % newps = 0;
% % keys = dagSamples.HT.keys();
% % while keys.hasMoreElements()
% % 	key = keys.nextElement();
% % 	value = dagSamples.HT.get(key);
% % 
% % 	newps = newps + value(2)/dagSamples.nSamples*value(3);
% % 		
% % end
% % 
