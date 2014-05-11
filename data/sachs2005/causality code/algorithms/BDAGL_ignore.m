function model = BDAGL_ignore( indata, maxFanIn )
% ignores target variables

    indata.targets = zeros( size( indata.targets ));
    model = BDAGL_perfect( indata, maxFanIn );
    model.nll = @my_nll2;
end

function nll = my_nll2( model, indata)
% ignores targets
    
    data = indata.X;
    clamped = zeros( size( indata.targets ));
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