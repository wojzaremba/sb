function [bn_opt, runparams, options] = init_compute_roc_scores(network, arity, type, variance, N, num_exp, maxS, plot_flag, save_flag, f_sel)   

    % check that we are in the sb directory
    fulldir = strsplit('/',pwd);
    assert(strcmpi(fulldir{end},'sb'));
    
    rp = struct();
    rp.cpd_type = strtok(type, '_');
    rp.file_name = sprintf('%s_%s_arity%d_N%d',network, rp.cpd_type, arity, N);
    rp.dir_name = sprintf('results/%s/%s', get_date(), rp.file_name);
    
    if save_flag
        system( ['mkdir -p ' rp.dir_name]);
        rp.mat_file_command = sprintf('save %s/%s.mat', rp.dir_name, rp.file_name);
        fprintf('Will %s\n', rp.mat_file_command);
    else
        rp.mat_file_command = '';
    end
    
    rp.network = network;
    rp.arity = arity;
    rp.type = type;
    rp.variance = variance;
    rp.N = N;
    rp.num_exp = num_exp;
    rp.maxS = maxS;
    rp.plot_flag = plot_flag;
    rp.save_flag = save_flag;
    rp.f_sel = f_sel;
    
    bn_opt = struct('network', network, 'arity', 1, 'type', type, 'variance', variance, 'moralize', false);
    
    runparams = rp;
    options = get_classifier_options(rp);
end
