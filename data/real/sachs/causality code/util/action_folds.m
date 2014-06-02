function [trainfolds, testfolds] = action_folds(A, Nfolds, samples_unseen_action, unseen_action )

% based on Kfold, but takes the same number from each type of action

% David Duvenaud

unique_actions = unique( A, 'rows' );
num_unique_actions = size( unique_actions, 1 );

if nargin < 3
    samples_unseen_action = -1; 
end

if nargin < 4
    unseen_action = 1;
end

% sort the actions into different regimes, and randomize their order
for a = 1:num_unique_actions
    
    % find matching indices
    cur_i = find( sum(abs(A - repmat( unique_actions(a, :), size( A, 1 ), 1 )), 2) == 0);
    
    % permute them
    regime_samples{a} = cur_i( randperm( length(cur_i)))';    
end

N = size( A, 1 );



if samples_unseen_action == -2 
    assert( Nfolds <= num_unique_actions );
    % this mode means: take one action and make it the test set
    
    for i=1:Nfolds
        testfolds{i} = regime_samples{i};
        trainfolds{i} = setdiff( 1:N, regime_samples{i} );
    end
else
    ndx = 1;
    for i=1:Nfolds

        low(i) = ndx;
        Nbin(i) = fix(length(regime_samples{1})/Nfolds);   % warning: won't work well if there are different numbers of examples per regime
        if i==Nfolds
            high(i) = length(regime_samples{1});
        else
            high(i) = low(i)+Nbin(i)-1;
        end

        testfolds{i} = [];
        trainfolds{i} = [];

        for a = 1:num_unique_actions
            cur_samples = regime_samples{a};


            if samples_unseen_action == -1

                % normal way            
                cur_test_i = low(i):high(i);
                testfolds{i} = [ testfolds{i} cur_samples(cur_test_i) ];
                cur_training_i = setdiff(1:length(regime_samples{a}), cur_test_i );
                trainfolds{i} = [ trainfolds{i} cur_samples(cur_training_i)  ];        
            else

                % this is the mode where we only show a few samples of one action

                if a ~= unseen_action        
                    % if not the unseen action, show all examples
                    trainfolds{i} = [ trainfolds{i} cur_samples ];                
                else

                    % if this is the hidden example,
                    % put a small number in training and the rest in test

                    perm = randperm( length(cur_samples ));
                    cur_train_i = perm(1:samples_unseen_action);
                    cur_training = cur_samples( cur_train_i );
                    trainfolds{i} = [ trainfolds{i} cur_training  ];

                    cur_test_i = setdiff(1:length(regime_samples{a}), cur_train_i);
                    testfolds{i} = [ testfolds{i} cur_samples(cur_test_i) ];
                end
            end
        end

        ndx = ndx+Nbin(i);
    end
end