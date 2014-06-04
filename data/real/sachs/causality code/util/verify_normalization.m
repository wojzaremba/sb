% checks whether the probabilities sum to one


addpath( [ pwd, '/datasets/' ] );

% define datasets
datasets = cell(0);                  nicename = cell(0);
datasets{end + 1} = 'sanity_check';  nicename{ end + 1 } = 'Sanity Check';
datasets{end + 1} = 'sachs';         nicename{ end + 1 } = 'Sachs';


% choose which models to list
define_models();
models = cell(0);
%models{end + 1} = bernoulli_ig_struct;
%models{end + 1} = bernoulli_ind_struct;
%models{end + 1} = bernoulli_cond_struct;
%models{end + 1} = mob_ig_struct;
%models{end + 1} = mob_ind_struct;
models{end + 1} = ugm_ig_struct;
models{end + 1} = ugm_ind_struct;
%models{end + 1} = bdagl_perfect_struct;
%models{end + 1} = bdagl_uncertain_struct;
total = 0;


for d=2%:length(datasets)
    
    load(datasets{d}); % X is an n x d matrix of discrete data
    %X = canonizeLabels(X);
    
    % make it smaller
    %X = X( 1:100, 1:5 );

    for m=1:length(models)

     %   arity = max(X(:));  
        [n, dim] = size(X);

        data_train.X = X;
        data_train.A = A;
        data_train.targets = targets;
        data_train.nStates = nStates;

        data_test.X = ind2subv( ones( 1, dim) * nStates, 1:nStates^dim );
        data_test.A = repmat(A( 1, : ), size( data_test.X, 1), 1 );
        % uncomment if you want to try a novel action
        % data_test.A = repmat(zeros(size(A( 1, : ))), size( data_test.X, 1), 1 );  
        data_test.targets = repmat(targets( 1, : ), size( data_test.X, 1), 1 );
        data_test.nStates = nStates;
        
        cur_model = models{m};
        
        fprintf('\nSumming %s on %s ( arity %d )', cur_model.name, datasets{d}, nStates );
        model = cur_model.fit( data_train, cur_model.params{end,:} );
        fprintf('...');
        
        nll = model.nll( model, data_test );
        total(m) = sum(exp(-nll));
        fprintf('total probability is %f', total(m) );
    end
end

fprintf('\nDone\n');

total


