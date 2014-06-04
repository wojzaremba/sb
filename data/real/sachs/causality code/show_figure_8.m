% Compare various density estimators on various categorical data sets
function show_results()

addpath( [ pwd, '/datasets/' ] );
addpath( [ pwd, '/util/' ] );

outdir = 'results/';

% define datasets
datasets = cell(0);                                       nicename = cell(0);                                   dActions = cell(0);
%datasets{end + 1} = 'mini_sachs';                         nicename{ end + 1 } = 'Mini Sachs';                   dActions{ end + 1 } = 6;
%datasets{end + 1} = 'sachs';                              nicename{ end + 1 } = 'Sachs';                        dActions{ end + 1 } = 9;
%datasets{end + 1} = 'SEMdata_8_3_hidden';                 nicename{ end + 1 } = 'SEM 8 nodes s3 hidden';        dActions{ end + 1 } = 28;
datasets{end + 1} = 'SEMdata_8_2_visible';                nicename{ end + 1 } = 'SEM 8 nodes s2 visible';       dActions{ end + 1 } = 28;


% choose which models to list
define_models();
models = cell(0);
%models{end + 1} = bernoulli_ig_struct;
models{end + 1} = mob_ig_struct;
models{end + 1} = ugm_p_ig_struct;
models{end + 1} = bdagl_ignore_struct;

%models{end + 1} = bernoulli_ind_struct;
%models{end + 1} = mob_ind_struct;
%models{end + 1} = ugm_p_ind_struct;

%models{end + 1} = bernoulli_cond_struct;
models{end + 1} = mob2_cond_struct;
models{end + 1} = ugm_cond_struct;
models{end + 1} = bdagl_uncertain_struct;

models{end + 1} = bdagl_perfect_struct;




modelnames = cell(length(models), 1 );

unseen = true;
Nfolds = 2;
nModels = length(models);   
nDatasets = length( datasets );

nll_big_table = NaN( nDatasets, nModels, Nfolds );

for d=1:length(datasets)
    
    if unseen
        Nfolds = dActions{d};
    end
    
    cur_dataset = datasets{d};         
    nll_table = NaN( nModels, Nfolds );
    
    % load summarized results
    load( cur_dataset );
    actual_dim(d) = size(X, 2 );
    actual_size(d) = size(X, 1 );

    for m=1:length(models)

        cur_model = models{m};
        modelnames{m} = cur_model.name;
        shortnames{m} = cur_model.shortname;
        typenames{m} = cur_model.typename;


        for f=1:Nfolds

            try                     
                if unseen
                    outfilename = sprintf('%sunseen %s on %s fold %d of %d.mat', outdir, cur_model.name, cur_dataset, f, Nfolds );
                else
                    outfilename = sprintf('%s%s on %s fold %d of %d.mat', outdir, cur_model.name, cur_dataset, f, Nfolds );
                end
                load( outfilename ); 

                nll_per = nll / size( full_nll, 1 );
                nll_table( m, f ) = nll_per;
                nll_big_table( d, m, f ) = nll_per;
                fprintf('.');

            catch e 
                fprintf('couldn''t load %s\n', outfilename );
            end                   
        end

    end

    
    if 1 && sum(~isnan( nll_table(:) )) > 0
        if unseen
            titlestring = sprintf('NLL on unseen actions on %s', nicename{d});
        else
            titlestring = sprintf('NLL on %s', nicename{d});
        end
        
        % now do the plots
        % relative to mean
        for a = 1:size(nll_table, 2 )
            rel_table( :, a ) = nll_table( :, a ) ./ nanmean( nll_table(:, a ));
        end
        boxplot( rel_table', 'labels', typenames ,'labelorientation', 'inline' );%, 'notch','on');                         
        title(titlestring);
        ylabel('Relative NLL' );
        set(gcf,'Position',[100,100,800,600])
        drawnow
        
        saveas( gcf, [ pwd '/figures/', titlestring, '.pdf' ] );
    end 
end

% numerical results table
% ==============================

% take the mean across all existing folds
nll_table_mean = mean( nll_big_table, 3 );

fprintf('\n\n\n                                ');
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
  
