function out = bn_learn_real(in)

[rp, learn_opt, bn_opt, SHD, T] = init(in);
loop = flatten_loop(rp.num_bnet, rp.num_nrep);
[bnet, bn] = generate_bnets(bn_opt, loop, rp.num_bnet, rp.data_gen);
[s, ti] = deal(zeros(length(loop), 1));

for t = 1:length(learn_opt)
    opt = learn_opt{t};
    for ni = 1:length(rp.nvec)
        n = rp.nvec(ni);
        parfor l = 1:length(loop)
            rng(l, 'twister'); % seed random numbers
            data = normalize_data(samples(bnet{l}, n));
            [s(l), ti(l)] = learn_structure(data, opt, rp, n);  
            printf(2, 'bnet=%d, nrep=%d, shd=%d\n', ...
                loop{l}.i, loop{l}.j, s(l));
        end
        [SHD{t}, T{t}] = populate_ST(SHD{t}, T{t}, rp, s, ti, ni);
        update_plot(SHD, T, t, ni, rp, learn_opt);
    end
end

[out.SHD, out.T, out.bn_opt, out.rp, out.learn_opt, out.bnet] ...
    = deal(SHD, T, bn_opt, rp, learn_opt, bn);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [SHD, t] = learn_structure(data, opt, rp, n)
    if (strcmpi(opt.method, 'sb3') || strcmpi(opt.method, 'bic'))
        data = discretize_data(data, opt.arity);
        [S, t1] = compute_score(data, opt, rp, n);
        [G, t2] = run_gobnilp(S);
        t = t1 + t2;
    elseif strcmpi(opt.method, 'mmhc')
        [G, t] = mmhc(data', opt.arity);
    else
        error('unexpected opt.method');
    end
    SHD = compute_shd(G, rp.true_pdag, false);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SHD = compute_shd(G, true_pdag, print_flag)
    pred_Pdag = dag_to_cpdag(G);
    SHD = shd(true_pdag,pred_Pdag);
    if ( ~isequal(true_pdag, pred_Pdag) && print_flag )
        fprintf('predicted G:\n');
        disp(G);
        fprintf('predicted PDAG:\n');
        disp(pred_Pdag);
        fprintf('true PDAG: \n');
        disp(true_pdag);
    end
    fprintf('hamming distance = %d\n', SHD);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function update_plot(SHD, T, tmax, nmax, rp, learn_opt)
    if rp.plot_flag
        figure(1)
        hold on
        n = rp.nvec(1:nmax);
        [h1, h2] = deal(zeros(1, tmax));
        
        for t = 1:tmax
            subplot(1, 2, 1)
            hold on
            s = squeeze(mean(mean(SHD{t}, 1), 2));
            h1(t) = plot(n, s(1:nmax), learn_opt{t}.color, 'linewidth', 2);
            
            subplot(1, 2, 2)
            hold on
            time = squeeze(mean(mean(T{t}, 1), 2));
            h2(t) = plot(n, time(1:nmax), learn_opt{t}.color, 'linewidth', 2);
            leg{t} = learn_opt{t}.name;
        end
        
        subplot(1, 2, 1)
        xlabel('number of samples', 'fontsize', 14);
        ylabel('structural hamming distance', 'fontsize', 14);
        legend(h1, leg, 'fontsize', 12, 'location', 'Best');
        title(sprintf('Error, mean of %d bnets, %d reps', rp.num_bnet, rp.num_nrep));
        
        subplot(1, 2, 2);
        xlabel('number of samples', 'fontsize', 14);
        ylabel('run time (sec)', 'fontsize', 14)
        legend(h2, leg, 'fontsize', 12, 'location', 'Best');
        title('Runtime (sec)', 'fontsize', 14); 
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [S, T] = compute_score(data, opt, rp, n)
    tic;
    if ~opt.edge && isfield(opt, 'pval')
        opt.pval = false;
    end
    
    % preallocate
    pre = opt.prealloc(data, opt);
    
    % compute base scores
    if strcmpi(opt.method, 'bic')
        S = compute_bic(data, opt.arity, rp.maxpa);
    elseif strcmpi(opt.method, 'sb3')
        S = compute_rho_scores(pre, opt.prune_max, rp.nfunc);
    else
        error('unexpected value for score');
    end
    
    if opt.edge
        E = compute_edge_scores(data, opt, rp.max_condset, pre);
        S = add_edge_scores(S, E, rp.psi, n);
    end;
    S = prune_scores(S);
    T = toc;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [bnet, bn] = generate_bnets(bn_opt, loop, num_bnet, data_gen)
    bn = {};
    bnet = {};
    for i = 1:num_bnet
        bn{i} = make_bnet(bn_opt);
    end
    if num_bnet > 1
        field = 'weights';
        if strcmpi(data_gen, 'random')
            field = 'cpt';
        end
        assert(~isequal(get_field(bn{1}.CPD{end}, field), ...
            get_field(bn{end}.CPD{end}, field)));
    end
    for l = 1:length(loop)
        bnet{l} = bn{loop{l}.i};
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [SHD,T] = populate_ST(SHD, T, rp, s, t, ni)
    s = reshape(s, rp.num_nrep, rp.num_bnet)';
    t = reshape(t, rp.num_nrep, rp.num_bnet)';
    SHD(:, :, ni) = s;
    T(:, :, ni) = t;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [rp, learn_opt, bn_opt, SHD, T] = init(in)
    [rp, learn_opt, max_arity] = init_general(in);
    % XXX 
    if strcmpi(in.data_source, 'synthetic')
        [rp, SHD, T, bn_opt] = init_synthetic(learn_opt, rp, max_arity);
    elseif strcmpi(in.data_source, 'real')
        D = init_real(in.data);
    end
end

function [rp, learn_opt, max_arity] = init_general(in)

    check_dir();
    rp = in;
    learn_opt = get_learners(rp.f_sel);

    max_arity = 2;
    for f = 1:length(learn_opt)
        max_arity = max(max_arity, learn_opt{f}.arity);
    end
    
    for c = 1:length(learn_opt)
        o = learn_opt{c};
        if o.arity == 1
            str = ', cts data';
        else
            str = sprintf(', arity %d', o.arity);
        end
        if isfield(o, 'edge')
            str = [str sprintf(', %s edge scores', repmat('no', ~o.edge))];
        end
        if isfield(o, 'pval')
            str = [str sprintf(', %s pval', repmat('no', ~o.pval))];
        end
        learn_opt{c}.name = sprintf('%s%s', o.method, str);
    end
    
    if rp.save_flag
        check_dir();
        dir_name = sprintf('results/%s', get_date());
        system(['mkdir -p ' dir_name]);
        rp.matfile = sprintf('%s/%s_%s.mat', dir_name, rp.network, func2str(rp.nfunc));
    end
    
    if rp.plot_flag
        h = figure(1);
        set(h, 'units', 'inches', 'position', [4 4 12 8]);
    end

end

function [rp, SHD, T, bn_opt] = init_synthetic(learn_opt, rp, max_arity)
    SHD = cell(length(learn_opt), 1);
    T = cell(length(learn_opt), 1);
    for c = 1:length(learn_opt)
        SHD{c} = NaN*ones(rp.num_bnet, rp.num_nrep, length(rp.nvec));
        T{c} = NaN*ones(rp.num_bnet, rp.num_nrep, length(rp.nvec));
    end
    
    % XXX is this really what I want?
    a = 1;
    if strcmpi(in.data_gen, 'random')
        a = max_arity;
    end
    
    bn_opt = struct('network', rp.network, 'arity', a, ...
        'data_gen', rp.data_gen, 'variance', rp.variance, ...
        'moralize', false, 'n', rp.nvars);
    rp.true_pdag = dag_to_cpdag(get_dag(bn_opt));
end

function D = init_real(data)
    command = sprintf('load ''data/real/mats/%s.mat''', data);
    eval(command);
    assert(exist('D', 'var'));
end



