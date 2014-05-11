function model = BDAGL_perfect( indata, maxFanIn )
  
    % seperate actions and responses
    % note:
    % data should be in range 1-2
    % clamped should be in range 0 - 1

    data = indata.X;
    clamped = indata.targets;
    arity = indata.nStates;
    nNodes = size( data, 2 );


    if ( maxFanIn > nNodes - 1 )
        warning( 'maxfanin is greater than nNodes - 1')
        maxFanIn = nNodes - 1;
    end
    
    % perfect interventions
    aflp = mkAllFamilyLogPrior(nNodes, 'maxFanIn', maxFanIn);

    aflml = mkAllFamilyLogMargLik(data', 'maxFanIn', nNodes-1, 'nodeArity', arity*ones(1,nNodes), ...
       'clampedMask', clamped', 'impossibleFamilyMask', aflp~=-Inf, 'verbose', 1 );
    optimalDag_perfect = computeOptimalDag(aflml);

    ADTreePtrTrain = mkADTree( data, arity*ones(1,nNodes), 2 );


    model.optimalDag_perfect = optimalDag_perfect;
    model.ADTreePtrTrain = ADTreePtrTrain;
    model.nll = @my_nll;
end


function nll = my_nll( model, indata)

    data = indata.X;
    clamped = indata.targets;
    arity = indata.nStates;
    nNodes = size( data, 2 );

                         % logPredLikDagsMultiple( dags, logWeights, nodeArities, ADTreePtrTrain, testData, testClamped )                                                 
    nll = -mylogPredLikDagsMultiple( {model.optimalDag_perfect}, 0, arity*ones(1,nNodes), model.ADTreePtrTrain, data', clamped' );
    
    % note:  the distribution given by this method will not sum to one!!!
    %        this is because the clamped vector is giving it extra
    %        information, and it is actually returning a conditional
    %        distribution.  This is the correct behavior, and the fact that
    %        the distribution doesn't normalize just underlines the fact 
    %        that BDAGL_perfect is getting extra side information that the
    %        other algorithms aren't. 
  
  %  nll = -mylogPredLikDagsMultiple( {model.optimalDag_perfect}, 0, arity*ones(1,nNodes), model.ADTreePtrTrain, data', zeros(size(clamped')) );
end




