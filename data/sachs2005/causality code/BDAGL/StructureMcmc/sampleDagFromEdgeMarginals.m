function [dag lp isMod] = sampleDagFromEdgeMarginals( edgeProb, dag )

mmin = 1e-4;
mmax = 1 - mmin;

edgeProb(edgeProb<mmin) = mmin;
edgeProb(edgeProb>mmax) = mmax;

if nargin==1
	
	dag = zeros(size(edgeProb));
	for ci=1:length(edgeProb)
		for ri=(ci+1):length(edgeProb)
			prEdge = min(edgeProb(ci,ri) + edgeProb(ri,ci), 1-mmin);
			if rand<prEdge
				if rand<min(edgeProb(ri, ci)/prEdge, 1-mmin)
					dag( ri,ci ) = 1;
				else
					dag( ci,ri ) = 1;
				end
			end

		end
	end
	
end

% make it acyclic
isMod = false;
% culprits = find(diag(expm(dag))>1);
% if ~isempty(culprits)
% 	if all(culprits' == [1 5 7])
% 		ee = [];
% 		for ci=1:length(culprits)
% 			next = myintersect( find(dag(culprits(ci), :)), culprits );
% 			ee(ci) = next(1);
% 		end
% 		
% 		ri = ceil(rand*3);
% 		dag(culprits(ri), ee(ri)) = 0;
% 		dag(ee(ri), culprits(ri)) = 1;
% 		
% 	end
%end

% if ~acyclic(dag)
% 		NCYCLIC = NCYCLIC + 1;
% end

% while ~isempty(culprits)
% 	pivot = culprits(ceil(rand*length(culprits)));
% 	clip = myintersect( find(dag(:, pivot)), culprits );
% 	
% 	dag( clip( ceil(rand*length(clip)) ), pivot ) = 0;
% 	
% 	culprits = find(diag(expm(dag))>1);
% 	isMod = true;
% end

% compute lpr

lp = 0;

for ci=1:length(edgeProb)
	for ri=(ci+1):length(edgeProb)
		prEdge = min(edgeProb(ci,ri) + edgeProb(ri,ci), 1-mmin);
		if (dag(ri,ci)+dag(ci,ri))>0
			lp = lp + log( prEdge );
			if edgeProb>1
				keyboard;
			end
			prRiCi = min(edgeProb(ri, ci)/prEdge, 1-mmin);
			if dag(ri,ci)>0
				dag( ri,ci ) = 1;
				
				lp = lp + log(prRiCi);
			else
				dag( ci,ri ) = 1;	
				
				lp = lp + log(1-prRiCi);
			end
		else
			lp = lp + log(1-prEdge);
		end
		
	end
end