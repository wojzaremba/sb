function full_ignore_nll = nll_ignoring_targets( model, data, full_nll )
% evaluates the nll, but then normalizes based on the probability that the
% target node was set to the value it was.  This is so that the models are
% evaluated on an equal footing with BDAGL-perfect.

% first, find all the different types of targets
targets = data.targets;
X = data.X;
arity = data.nStates;
A = data.A;

full_ignore_nll = full_nll;

unique_target_sets = unique( targets, 'rows' );
num_unique_target_sets = size( unique_target_sets, 1 );

for t = 1:num_unique_target_sets

    cur_target_set = unique_target_sets( t, : );
    
    % get all the rows with this target set
    cur_target_rows = find( sum( abs(repmat( cur_target_set, size( X, 1), 1 ) - targets ),2) == 0 );
    
    % now, find all different types of activated variables within this set
    % of targets ( synthetic datasets with perfect interventions should
    % only have one )    
    cur_active_columns = cur_target_set == 1;
    cur_row_states = X( cur_target_rows, find(cur_target_set) );
    unique_targeted_variable_states = unique( cur_row_states, 'rows' );
    
    num_unique_targeted_variable_states = size( unique_targeted_variable_states, 1 );
    
    % generate the dataset of all combinations
    holes_per_row = sum(cur_active_columns == 0);
    all_possible = ind2subv( ones( 1, holes_per_row) * arity, 1:arity^holes_per_row );
    n_possible = size( all_possible, 1 );
    
    % assuming that actions are the same when the targets are the same, we
    % can grab a representative
    cur_action_state = A(cur_target_rows(1), : );

    for s = 1:num_unique_targeted_variable_states
    
        % find all combinations of data having this set of targets
        % randomly choose some columns to remove
        holes = cur_target_set == 0;

        cur_row = NaN( 1, size( X, 2 ));
        cur_row( cur_active_columns ) = unique_targeted_variable_states( s, : );
        copied_data = repmat( cur_row, n_possible, 1 );

        % stick it in the right columns
        copied_data(:,holes) = all_possible;
        
        % evaluate the nll ( could be unnormalized for speed if we want )
        small_data.X = copied_data;
        small_data.nStates = arity;
        small_data.targets = repmat( cur_target_set, n_possible, 1 );
        small_data.A = repmat( cur_action_state, n_possible, 1 ); 
        
        nll_u = model.nll( model, small_data );
        
        % find the log normalization constant
        logZ = logsumexp(-nll_u);        
        %assert( logZ <= 0 );
        
        % find the appropriate sub rows among cur_target_rows
        sub_rows = find( sum(abs(repmat( cur_row( cur_active_columns ), size(cur_target_rows, 1), 1) - X( cur_target_rows, cur_active_columns)), 2) == 0 );
        
        % subtract it from the nll of the appropriate rows
        full_ignore_nll( sub_rows ) = full_ignore_nll( sub_rows ) + logZ;
    end
end


