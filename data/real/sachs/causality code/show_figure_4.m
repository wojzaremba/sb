% Compare various density estimators on various categorical data sets
function show_results()

samples_unseen_action = [ 0 ];
%samples_unseen_action = [ 50 100 200 500 ];
Nfolds = 2;  % this must be set by hand
max_actions = 8;

addpath( [ pwd, '/datasets/' ] );
addpath( [ pwd, '/util/' ] );
outdir = 'results/';


% define datasets
datasets = cell(0);                        nicename = cell(0);
datasets{end + 1} = 'sachs';               nicename{ end + 1 } = 'Sachs';


% choose which models to list
define_models();
models = cell(0);
models{end + 1} = mob_ig_struct;
models{end + 1} = ugm_p_ig_struct;
models{end + 1} = bdagl_ignore_struct;
models{end + 1} = mob2_cond_struct;
models{end + 1} = ugm_cond_struct;
models{end + 1} = bdagl_uncertain_struct;
models{end + 1} = bdagl_perfect_struct;


modelnames = cell(length(models), 1 );
nModels = length(models);   
nDatasets = length( datasets );
nll_big_table = NaN( nDatasets, nModels, Nfolds, length(samples_unseen_action), max_actions );
colors = getColors;
symbols = getSymbols;


for d=1:length(datasets)
    
    cur_dataset = datasets{d};    
     
    nll_table = NaN( nModels, Nfolds );

    load( cur_dataset );
    actual_dim(d) = size(X, 2 );
    actual_size(d) = size(X, 1 );

        
    figure;
    titlestring = sprintf('NLL vs data on %s', nicename{d});
    
    for m=1:length(models)

        cur_model = models{m};
        modelnames{m} = cur_model.name;
        shortnames{m} = models{m}.shortname;
        typenames{m} = models{m}.typename;

        for unseen_action = 1:max_actions
            for t = 1:length(samples_unseen_action)
                for f=1:Nfolds

                    try                     

                        outfilename = sprintf('%s%s on %s fold %d of %d samples %d action %d.mat', outdir, cur_model.name, cur_dataset, f, Nfolds, samples_unseen_action(t), unseen_action );
                        load( outfilename );  
                        
                        nll_per = nll / size( full_nll, 1 );
                        nll_table( m, f ) = nll_per;
                        nll_big_table( d, m, f, t, unseen_action ) = nll_per;
                        
                        fprintf('.');
                    catch e 
                        fprintf('Failed to load %s on %s fold number %d\n', cur_model.name, cur_dataset, f );
                    end                   
                end
            end
        end
    end     
       
    little_table = squeeze(nll_big_table( 1, :, :, 1, : ));
    little_table = squeeze(mean( little_table, 2 ));
    
    
    % relative
    for a = 1:size(little_table, 2 )
    	rel_table( :, a ) = little_table( :, a ) ./ nanmean( little_table(:, a ));
    end
    boxplot( rel_table', 'labels', shortnames ,'labelorientation', 'inline' );
    titlestring = 'Unseen_Actions_on_Sachs';
    %title() ;
    ylabel('Relative NLL');
    
    saveas( gcf, [ pwd '/figures/', titlestring, '.pdf' ] );
    
end


% results table
if 1
    % take the mean across all existing folds
    nll_table_mean = mean( nll_big_table, 3 );

    fprintf('                                ');
    for d=1:length(datasets)
        fprintf('& %15s ', datasets{d} );
    end
    fprintf('\\\\ \n----------------------------------------------------------------------------------------------- \\\\ \n');

    for m=1:length(models)

        cur_model = models{m};
        modelname = cur_model.name;
        fprintf(' %30s &', modelname ); 

        for d=1:length(datasets)
            fprintf( '    %7.5f     & ', nll_table_mean( d, m ));  
        end
        fprintf('\n');
       
    end
  
end