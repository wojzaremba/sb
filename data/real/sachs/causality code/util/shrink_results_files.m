% shrinks the results files

outdir = 'results/';

files = dir( [ pwd '/*.mat' ] );
    
for i = 1:length( files )
    cur_filename = files(i).name;
    
    load( cur_filename);
    
    save( cur_filename, 'N', 'dim', 'nll', 'full_nll', 'train_time', 'validation_nll' );
    
    fprintf('.');
end
            
    
