% Compare various density estimators on various categorical data sets
function show_results()

samples_unseen_action = [ 10 20 35 50 100 200 ];
Nfolds = 2;  % this must be set by hand
max_actions = 7;
markersize = 12;

savesummary = true;
loadsummary = false;

addpath( [ pwd, '/datasets/' ] );
addpath( [ pwd, '/util/' ] );

%outdir = 'results/5th_july/';
%outdir = 'results/';
%outdir = 'results_set2/';
%outdir = 'results_set3/';
outdir = 'results/';


% define datasets
datasets = cell(0);                        nicename = cell(0);
%datasets{end + 1} = 'sanity_check';        nicename{ end + 1 } = 'Sanity Check';
datasets{end + 1} = 'sachs';               nicename{ end + 1 } = 'Sachs';
%datasets{end + 1} = 'allsame_binary_dag_nohidden_diag';   nicename{ end + 1 } = 'Allsame Binary DAG Perfect Diag';
%datasets{end + 1} = 'allsame_binary_dag_nohidden_pairs';  nicename{ end + 1 } = 'Allsame Binary DAG Perfect Pairs';
%datasets{end + 1} = 'allsame_binary_dag_hidden_diag';     nicename{ end + 1 } = 'Allsame Binary DAG Hidden Diag';
%datasets{end + 1} = 'allsame_binary_dag_hidden_pairs';    nicename{ end + 1 } = 'Allsame Binary DAG Hidden Pairs';

% choose which models to list
define_models();
models = cell(0);                           group_i = NaN(0); model_i = NaN(0);
%models{end + 1} = mob_ig_struct;            group_i(end+1) = 1; model_i(end+1) = 1;
models{end + 1} = ugm_p_ig_struct;          group_i(end+1) = 1; model_i(end+1) = 2;


%models{end + 1} = bernoulli_ind_struct;
%models{end + 1} = mob_ind_struct;           group_i(end+1) = 2; model_i(end+1) = 1;
models{end + 1} = ugm_p_ind_struct;         group_i(end+1) = 2; model_i(end+1) = 2;

%models{end + 1} = bernoulli_cond_struct;
%models{end + 1} = mob2_cond_struct;         group_i(end+1) = 3; model_i(end+1) = 1;
%models{end + 1} = mob_cond_c2_struct;
models{end + 1} = ugm_cond_struct;          group_i(end+1) = 3; model_i(end+1) = 2;
models{end + 1} = bdagl_ignore_struct;      group_i(end+1) = 1; model_i(end+1) = 3;
models{end + 1} = bdagl_uncertain_struct;   group_i(end+1) = 3; model_i(end+1) = 3;

models{end + 1} = bdagl_perfect_struct;     group_i(end+1) = 4; model_i(end+1) = 3;




intermediate_dir = 'plotting_summaries/';

modelnames = cell(length(models), 1 );


nModels = length(models);   
nDatasets = length( datasets );

nll_big_table = NaN( nDatasets, nModels, Nfolds, length(samples_unseen_action), max_actions );

colors = {'r','b',[0 .5 0],[.5 0 .5],[0 .5 1],[1 .5 0],};
symbols = getSymbols;

for zoom_action = 7
for d=1:length(datasets)
    
    cur_dataset = datasets{d};    
     
    nll_table = NaN( nModels, Nfolds );

    load( cur_dataset );
    actual_dim(d) = size(X, 2 );
    actual_size(d) = size(X, 1 );

        
    figure;
    titlestring = sprintf('NLL_vs_data_on_%s_action_%d', nicename{d}, zoom_action);
    
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
                        %dims( d) = dimensionality;
                        
                        fprintf('.');
                    catch e 
                        fprintf('Failed to load %s\n', outfilename );
                    end                   
                end
            end
        end
            
        % take the averages
        sub_table = squeeze(nll_big_table( d, m, :, :, : ));
        for t = 1:length(samples_unseen_action)
            sub_sub_table = sub_table( :, t, zoom_action );
            
            avg(t) = NaN;
            avg(t) = mean( sub_sub_table(:) );
            
            sd(t) = NaN;
            sd(t) = std( sub_sub_table(:) );
            
            if t == 1
                row = mean( sub_sub_table, 1 );
            end
        end                    
                
        % now do the plots  
        
        % todo: add error bars
        h = plot( samples_unseen_action, avg, 'o-'); hold on;
        set(h,'MarkerFaceColor',[1 1 .9]);
        set(h,'markersize',markersize,'linewidth',2,'marker',symbols{model_i(m)},'color',colors{m});  
       
        h = text( samples_unseen_action(5), avg(5), shortnames{m} );
        set(h,'color',colors{m}); 
        set(h,'FontName','AvantGarde','FontSize',14,'FontWeight','normal');
        
        switch group_i(m)
            case 1
                set(h,'LineStyle','--');
            case 2
                set(h,'LineStyle','-.');
            case 3
                set(h,'LineStyle',':');
            case 4
                set(h,'LineStyle','-');
        end
        drawnow;
        
        little_table( m, : ) = avg;
    end     
    
    % load it here also
    
    %prettyPlot(repmat( samples_unseen_action, m ,1 ), little_table, typenames, 'title', plotXlabel,plotYlabel,group_i,model_i,errors)
   % prettyplot( 
    
    %legend( shortnames, 'Location', 'best' );

%     legendStr = shortnames;
%     if ~isempty(legendStr)
%         h = legend(legendStr);
%         set(h,'FontSize',10,'FontWeight','normal');
%         set(h,'Location','Best');
%     end
    
   % h = title(titlestring);
    %set(h,'FontName','AvantGarde','FontSize',10,'FontWeight','bold');

    h1 = xlabel('Number of training examples of unseen action');
    h2 = ylabel('Average Negative Log-Likelihood');
    set([h1 h2],'FontName','AvantGarde','FontSize',14,'FontWeight','normal');
    
    set(gca,'FontName','AvantGarde','FontWeight','normal','FontSize',12);



    set(gcf,'Position',[100,100,800,600]);
    drawnow;
    
    xlim( [samples_unseen_action( 1), samples_unseen_action(end)]);


    %title(sprintf('action %d', zoom_action));
    saveas( gcf, [ pwd '/figures/', titlestring, '.png' ] );   
    saveas( gcf, [ pwd '/figures/', titlestring, '.fig' ] );  
    saveas( gcf, [ pwd '/figures/', titlestring, '.pdf' ] );
    
    %prettyplot
   
    
%     % relative
%     for a = 1:size(little_table, 2 )
%     	rel_table( :, a ) = little_table( :, a ) ./ mean( little_table(:, a ));
%     end
%     figure;
%     boxplot( rel_table', 'labels', shortnames ,'labelorientation', 'inline' );
%     title('Unseen actions on Sachs') ;
%     ylabel('Relative NLL');
    
end
end
%placeFigures('minwidth',250,'minheight',250)


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