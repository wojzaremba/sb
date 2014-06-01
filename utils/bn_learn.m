function out = bn_learn(in)

[bn_opt, rp, learn_opt, SHD, T] = init(in);
loop = flatten_loop(rp.num_bnet,rp.num_nrep);
[bnet, bn] = generate_bnets(bn_opt, loop, rp.num_bnet, rp.data_gen);
[s, ti] = deal(zeros(length(loop), 1));

for t = 1:length(learn_opt)
    opt = learn_opt{t};
    for ni = 1:length(rp.nvec)
        n = rp.nvec(ni);
        parfor l = 1:length(loop)
            rng(l, 'twister');
            data = normalize_data(samples(bnet{l}, n));
            [s(l), ti(l)] = learn_structure(data, opt, rp, n);  
            printf(2, 'bnet=%d, nrep=%d, shd=%d\n', loop{l}.i, loop{l}.j, s(l));
        end
        [SHD{t}, T{t}] = populate_ST(SHD{t}, T{t}, rp, s, ti, ni);
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
function update_plot(b, r, rp, learn_opt, SHD, T)
clf;
[h1, h2, leg] = deal([], [], {});
for c = 1 : length(learn_opt)
    leg{end+1} = learn_opt{c}.name;
    
    subplot(1, 2, 1); hold on
    ham = SHD{c}(1:b, 1:r, :);
    h1(end+1) = plot(rp.nvec, squeeze(mean(mean(ham, 1), 2)), ...
        learn_opt{c}.color, 'linewidth', 2);
    
    subplot(1, 2, 2); hold on
    tt = T{c}(1:b, 1:r, :);
    h2(end+1) = plot(rp.nvec, squeeze(mean(mean(tt, 1), 2)), ...
        learn_opt{c}.color, 'linewidth', 2);
end

subplot(1, 2, 1);
legend(h1, leg);
yl = ylim;
ylim([0 yl(2)]);
xlabel('number of samples');
ylabel('structural hamming distance');
title(sprintf('SHD vs. N, %s network, %d parameter settings, %d reps', ...
    rp.network, b, r), 'fontsize', 14);

subplot(1, 2, 2);
legend(h2, leg);
xlabel('number of samples');
ylabel('runtime (sec)');
title(sprintf('Runtime vs. N, %s network, %d parameter settings, %d reps', ...
    rp.network, b, r), 'fontsize', 14);
pause(2);
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
        if strcmpi(data_gen, 'random')
            field = 'cpt';
        else
            field = 'weights';
        end
        assert(~isequal(get_field(bn{1}.CPD{end}, field), ...
            get_field(bn{end}.CPD{end}, field)));
    end
    
    for l = 1:length(loop)
        bnet{l} = bn{loop{l}.i};
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [S,T] = populate_ST(S, T, rp, s, t, ni)
    s = reshape(s, rp.num_nrep, rp.num_bnet)';
    t = reshape(t, rp.num_nrep, rp.num_bnet)';
    S(:, :, ni) = s;
    T(:, :, ni) = t;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [bn_opt, rp, learn_opt, SHD, T] = init(in)

check_dir();
rp = in;

full_opt = {
    struct('method', 'mmhc', 'arity', 3, 'edge', false, ...
    'color', 'g-'), ...
    struct('method', 'sb3', 'classifier', @kci_classifier, ...
    'kernel', GaussKernel(),  'arity', 1, 'nfunc', rp.nfunc, ...
    'prealloc', @kci_prealloc, 'pval', false, ...
    'edge', true, 'prune_max', rp.prune_max, 'color', 'm-'), ...
    struct( 'method', 'sb3', 'classifier', @kci_classifier, ...
    'kernel', GaussKernel(),  'arity', 1, 'nfunc', rp.nfunc, ...
    'prealloc', @kci_prealloc, 'pval', true, ...
    'edge', true, 'prune_max', rp.prune_max, 'color', 'r-'), ...
    struct('method', 'bic','classifier', @sb_classifier, ...
    'params', struct('eta', 0.01, 'alpha', 1.0), ...
    'prealloc', @dummy_prealloc, 'arity', 4, ...
    'edge', false, 'color','b-')};
learn_opt = full_opt(in.f_sel);

if rp.plot_flag
    figure
end

SHD = cell(length(learn_opt), 1);
T = cell(length(learn_opt), 1); 

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
    
    SHD{c} = NaN*ones(rp.num_bnet, rp.num_nrep, length(rp.nvec));
    T{c} = NaN*ones(rp.num_bnet, rp.num_nrep, length(rp.nvec));
end

if rp.save_flag
    check_dir();
    dir_name = sprintf('results/%s', get_date());
    system(['mkdir -p ' dir_name]);
    rp.matfile = sprintf('%s/%s_%s.mat', dir_name, rp.network, func2str(rp.nfunc));
end

if strcmpi(in.data_gen, 'random')
    a = full_opt{4}.arity;
else
    a = 1;
end

bn_opt = struct('network', in.network, 'arity', a, ...
    'data_gen', in.data_gen, 'variance', in.variance, ...
    'moralize', false, 'n', in.nvars);
rp.true_pdag = dag_to_cpdag(get_dag(bn_opt));

end
    


