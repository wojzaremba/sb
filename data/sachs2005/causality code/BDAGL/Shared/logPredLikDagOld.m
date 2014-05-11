function lpl = logPredLikDag( dag, parms, nodeArity, testData, testClamped )
% logPredLikDag(dag, parms, arities, singleTestPoint) must be equivalent to 
% logMargLikDag(dag, aflmlp) - logMargLikDag(dag, aflmlTrain) where aflmlp has
% been generated based on the augmented dataset [dataTrain singleTestPoint]
% if this is not the case, there is a bug ;)


if nargin<5
    
    lpl = 0;

    for i=1:length(dag) % loop over nodes (children)

        ps = find( dag(:,i) )';

        k_all = testData(i, :)';
        js_all = testData(ps, :)';

        j = subv2ind( nodeArity([ps i]), [js_all k_all] );

        lpl = lpl + sum(log( parms{i}(j) ));

    end

else
 
    % clamped cases contribute log(1) to the log pred lik
    
    lpl = 0;

    for i=1:length(dag) % loop over nodes (children)

        ps = find( dag(:,i) )';

        unclampedInds = testClamped(i,:)==0;
        k_all = testData(i, unclampedInds )';
        js_all = testData(ps, unclampedInds )';

        j = subv2ind( nodeArity([ps i]), [js_all k_all] );

        lpl = lpl + sum(log( parms{i}(j) ));

    end
    
end