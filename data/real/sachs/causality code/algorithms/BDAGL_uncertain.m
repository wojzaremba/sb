function model = BDAGL_uncertain( indata, maxFanIn )

    % seperate actions and responses

    data = indata.X;
    actions = indata.A + 1;
    nStates = indata.nStates;
    
    nObservations = size( data, 2 );      % number of observation nodes
    nInterventions = size( actions, 2 );  % number of action nodes
    
    combined_data = [ actions data ];
       
    clamped_mask = [ones(nInterventions, size(data,1)) ; zeros(nObservations, size(data,1)) ]; 
       
    % todo: get rid of the magic number 2
    if ( maxFanIn > nObservations - 2 )
        warning( 'maxfanin is greater than nObservations - 3')
        maxFanIn = nObservations - 2;
    end

    nNodes_total = nObservations + nInterventions;
    arity = [repmat(2, 1, nInterventions) repmat(nStates, 1, nObservations)];
    maxFanIn = [ 0 2 ; ...
                 0 maxFanIn + 2 ];
    layering = [ ones(1, nInterventions) 2*ones(1, nObservations) ];
    aflp_uncertain = mkAllFamilyLogPrior(nNodes_total, 'maxFanIn', maxFanIn, 'nodeLayering', layering);
    aflml_uncertain = mkAllFamilyLogMargLik(combined_data', 'maxFanIn', maxFanIn, ...
       'nodeArity', arity, 'clampedMask', clamped_mask, 'impossibleFamilyMask', aflp_uncertain~=-Inf, 'verbose', 1 );
    optimalDag_uncertain = computeOptimalDag(aflml_uncertain);

    ADTreePtrTrain = mkADTree( combined_data, arity, 2 );

    model.optimalDag_uncertain = optimalDag_uncertain;
    model.ADTreePtrTrain = ADTreePtrTrain;
    model.nll = @my_nll;
end


function nll = my_nll( model, indata )

    data = indata.X;
    actions = indata.A + 1;
    nStates = indata.nStates;
    
    nNodes = size( data, 2 );   
    nObservations = nNodes;
    nInterventions = size( actions, 2 );
    
    combined_data = [ actions data ];
       
    clamped_mask = [ones(nInterventions, size(data,1)) ; zeros(nObservations, size(data,1)) ]; 
       
    arity = [repmat(2, 1, nInterventions) repmat(nStates, 1, nObservations)];
    
    nll = -mylogPredLikDagsMultiple( {model.optimalDag_uncertain}, 0, arity, model.ADTreePtrTrain, combined_data', clamped_mask );
end






