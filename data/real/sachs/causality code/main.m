function main_v3( model_i, dataset_i, Nfolds, checkforold, samples_unseen_action, unseen_action )
% Main experiment file
%
% Takes a set of models and datasets, creates training and test splits, and
% runs each model on each dataset on each fold, and records the results.
%
% David Duvenaud
% July 2009
% ==================================================
%
%
% arguments
% =============
%
% model_i      - a list of indices of models to run
% dataset_i    - a list of indices of datasets to run
% Nfolds       - the number of folds in the training data
% checkforold  - if true, skips jobs that have already been done.
% samples_unseen_action - how many samples do the algorithms get to learn
%           on for an unseen action?
%           default is -1, which means the same number for all.  If you use
%           the default, you don't have to set the 'unseen action' param.
%           -2 means test on totally unseen actions, each fold being a
%           different action, and ignoring the 'unseen_action' parameter
% unseen_action - which action should be unseen?
%
% for examples of how to call this function, see reproduce_figures.m

outdir = 'results/';


% define datasets
datasets = cell(0);                                       nicename = cell(0);                                   dActions = cell(0);
datasets{end + 1} = 'mini_sachs';                         nicename{ end + 1 } = 'Mini Sachs';                   dActions{ end + 1 } = 6;
datasets{end + 1} = 'sachs';                              nicename{ end + 1 } = 'Sachs';                        dActions{ end + 1 } = 9;
datasets{end + 1} = 'SEMdata_8_3_hidden';                 nicename{ end + 1 } = 'SEM 8 nodes s3 hidden';        dActions{ end + 1 } = 28;
datasets{end + 1} = 'SEMdata_8_2_visible';                nicename{ end + 1 } = 'SEM 8 nodes s2 visible';       dActions{ end + 1 } = 28;


% choose which models to list
define_models();
models = cell(0);
models{end + 1} = bernoulli_ig_struct;
models{end + 1} = bernoulli_ind_struct;
models{end + 1} = bernoulli_cond_struct;
models{end + 1} = mob_ig_struct;
models{end + 1} = mob_ind_struct;
models{end + 1} = mob2_cond_struct;
models{end + 1} = ugm_p_ig_struct;
models{end + 1} = ugm_p_ind_struct;
models{end + 1} = ugm_cond_struct;
models{end + 1} = bdagl_ignore_struct;
models{end + 1} = bdagl_perfect_struct;
models{end + 1} = bdagl_uncertain_struct;



% argument defaults
if ( nargin < 4 ), checkforold = false; end
if ( nargin < 3 ), Nfolds = 2; end
if ( nargin < 5 ), samples_unseen_action = -1; end
if ( nargin < 6 ), unseen_action = 1; end
if ( nargin < 2 ), dataset_i = 1:length(datasets ); end
if ( nargin < 1 ), model_i = 1:length(models); end


for d_ix =dataset_i
    
    % load the dataset
    cur_dataset = datasets{d_ix};   
    load(cur_dataset); % X is an n x d matrix of discrete data
    % all the causality datasets should have X, A and targets
    
    % check that the dataset is canonized
    Y = canonizeLabels(X);   
    if any(X ~= Y )
        warning( sprintf('dataset %s isnt canonized', cur_dataset ));
    end
    X = Y;            
    [ N, dim ] = size(X);
        
    % make training and test sets
    setSeed(100);
    
    [trainfolds, testfolds] = action_folds(A, Nfolds, samples_unseen_action, unseen_action);
        
    for m=model_i

        cur_model = models{m};

        for f=1:Nfolds
            
            setseed( f );  % so that it is the same every time, even if some folds are skipped

            % set up train and test sets
            data_train.X = X(trainfolds{f},:);
            data_train.A = A(trainfolds{f},:);
            data_train.targets = targets(trainfolds{f},:);
            data_train.nStates = nStates;
            
            data_test.X = X(testfolds{f},:);
            data_test.A = A(testfolds{f},:);
            data_test.targets = targets(testfolds{f},:);
            data_test.nStates = nStates;
            

            if samples_unseen_action == -2
                fprintf('\nRunning unseen %s on %s on fold %d...', cur_model.name, cur_dataset, f );             
                outfilename = sprintf('%sunseen %s on %s fold %d of %d.mat', outdir, cur_model.name, cur_dataset, f, Nfolds );
            else
                if samples_unseen_action == -1
                    fprintf('\nRunning %s on %s on fold %d...', cur_model.name, cur_dataset, f );             
                    outfilename = sprintf('%s%s on %s fold %d of %d.mat', outdir, cur_model.name, cur_dataset, f, Nfolds );
                else                
                    fprintf('\nRunning %s on %s on fold %d samples %d of action %d...', cur_model.name, cur_dataset, f, samples_unseen_action, unseen_action );             
                    outfilename = sprintf('%s%s on %s fold %d of %d samples %d action %d.mat', outdir, cur_model.name, cur_dataset, f, Nfolds, samples_unseen_action, unseen_action );
                end
            end
            
            % check if file already exists
            if checkforold && exist( outfilename )
                fprintf('skipping %s,\n the output file already exists.\n', outfilename);
            else             
                % train the model
                tic;
                model = cur_model.fit( data_train, cur_model.params{end,:} );                
                train_time = toc;
                
                % evaluate nll
                fprintf('evaluating nll...');
                full_nll = model.nll( model, data_test);
                nll = sum(full_nll);              
                fprintf('%f', nll / size( full_nll, 1 ) );
                
                % record results in a fine-grained way so we don't have to repeat long jobs
                save( outfilename, 'N', 'dim', 'nll', 'full_nll', 'model', 'testfolds', 'train_time' );
            end
        end
    end
end

fprintf('\nDone all jobs.\n');