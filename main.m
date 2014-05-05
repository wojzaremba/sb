function main(network, arity, type, N, variance, num_exp, max_S)

%clear all;
global debug
debug = 0;
%close all;

if exist('variance','var')
    v = variance;
else
    v = [];
end

cpd_type = strtok(type, '_');

bn_opt = struct('variance', v, 'network', network, 'arity', 1, 'type', type);
bnet = make_bnet(bn_opt);

file_name = sprintf('%s_%s_arity%d_N%d',network, cpd_type, arity, N);
dir_name = sprintf('results/2014_04_30/%s', file_name);
system( ['mkdir -p ' dir_name]);
mat_file_command = sprintf('save %s/%s.mat', dir_name, file_name);
diary(sprintf('%s/%s.out', dir_name, file_name));
fprintf('Will %s\n', mat_file_command);

K = length(bnet.dag);
num_samples_range = N;
num_N = length(num_samples_range);
thresholds = 0:1e-3:1;
thresholds_mi = 0:1e-3:log2(arity);

empty = struct('name', 'none');
L = LinearKernel();
G = GaussKernel();

full_options = {struct('classifier', @kci_classifier, 'discretize',false,...
    'prealloc', @kci_prealloc, 'kernel', L,'thresholds', thresholds, ...
    'color', 'g-' ,'params',[],'normalize',true,'name','partial corr, cts data'), ...
    
    struct('classifier', @kci_classifier, 'discretize', false, ...
    'prealloc', @kci_prealloc, 'kernel', G, 'thresholds', thresholds, ...
    'color', 'b-','params',[],'normalize',true,'name','KCI gauss kernel, cts data'), ...
    
    struct('classifier', @kci_classifier, 'discretize',true, ...
    'prealloc', @kci_prealloc, 'kernel', L,'thresholds', thresholds, ...
    'color', 'g--' ,'params',[],'normalize',true,'name',sprintf('partial corr, arity=%d',arity)), ...
    
    struct('classifier', @kci_classifier,'discretize',true,...
    'prealloc', @kci_prealloc, 'kernel', G, 'thresholds', thresholds, ...
    'color', 'b--','params',[],'normalize',true,'name',sprintf('KCI gauss kernel, arity=%d',arity)), ...
    
    struct('classifier', @cc_classifier, 'discretize',true, ...
    'prealloc', @dummy_prealloc, 'kernel', empty, 'thresholds', thresholds, ...
    'color', 'r:','params',[],'normalize',false,'name',sprintf('cond corr, arity=%d',arity)), ...
    
    struct('classifier', @mi_classifier,'discretize',true, ...
    'prealloc', @dummy_prealloc, 'kernel', empty, 'thresholds', thresholds_mi, ...
    'color', 'm-.','params',[],'normalize',false,'name',sprintf('cond MI, arity=%d',arity))};


options = full_options([2 4 5 6]);
num_classifiers = length(options);
name = cell(1,num_classifiers);
TPR = cell(num_classifiers, num_N);
FPR = cell(num_classifiers, num_N);

% label each pair of variables according to whether there is an edge
% between them
triples = gen_triples(K, max_S);
no_edge = zeros(length(triples),1);
fprintf('Computing ground truth existence of edges...\n');
tic;
for t = 1 : length(triples)
    i = triples{t}.i;
    j = triples{t}.j;
    no_edge(t) = ~(bnet.dag(i,j) || bnet.dag(j,i));
end
fprintf('...finished in %d seconds.\n',toc);
num_edge = length(no_edge) - length(find(no_edge));
fprintf('Testing %d no-edge and %d edge distributions, arity=%d.\n',length(find(no_edge)),num_edge,arity);

% allocate
for c = 1:num_classifiers
    o = options{c};
    name{c} = o.name;
    
     param_size{c} = [];
%     if (isstruct(o.params))
%         fields = fieldnames(o.params);
%         for i = 1:length(fields)
%             param_size{c} = [param_size{c} length(o.params.(fields{i}))];
%         end
%     end

end

total_time = 0;

for exp = 1:num_exp
    time_N = zeros(num_N,1);
    time_exp = 0;

    for N_idx = 1:num_N
        
        num_samples = num_samples_range(N_idx);
        fprintf('STARTING N=%d.\n',num_samples);
        
        fprintf('Experiment #%d, N=%d, sampling from bayes net...\n',exp,num_samples);
        s = samples(bnet, num_samples);
        fprintf('... done.\n');
        s = normalize_data(s); % XXX don't want to always do this in general
        s_disc = discretize_data(s, arity);
        
        for c = 1:num_classifiers
            tic;
            o = options{c};
            opt = struct('arity', arity, 'kernel', o.kernel,'thresholds', o.thresholds,'params',o.params, 'normalize',o.normalize);
            
            % allocate
            num_thresholds = length(o.thresholds);
            scores = zeros([2 2 num_thresholds param_size{c}]);
            
            if o.discretize
                emp = s_disc;
            else
                emp = s;
            end            
            
            % apply classifier
            prealloc = o.prealloc(emp, opt);
            for t = 1 : length(triples)
                
                % evaluate classifier at all thresholds in thresholds
                rho = classifier_wrapper(emp, triples{t}, o.classifier, opt, prealloc);

                indep_emp = threshold(opt.thresholds,rho);
                indep_emp = reshape(indep_emp,[1 1 size(indep_emp)]);
                
                % increment scores accordingly (WARNING: HARD-CODED max num
                % params to optimize as 2)
                scores(1 + no_edge(t),1,:,:,:) = scores(1 + no_edge(t),1,:,:,:) + ~indep_emp;
                scores(1 + no_edge(t),2,:,:,:) = scores(1 + no_edge(t),2,:,:,:) + indep_emp;
               
            end
    
            P = scores(2, 1, :, :, :) + scores(2, 2, :, :, :);
            N = scores(1, 1, :, :, :) + scores(1, 2, :, :, :);
            TP = scores(2, 2, :, :, :);
            %TN = scores(1, 1, :, :, :);
            FP = scores(1, 2, :, :, :);
            TPR{c, N_idx}(exp, :, :, :) = squeeze(TP ./ P);
            FPR{c, N_idx}(exp, :, :, :) =  squeeze(FP ./ N);
            
            time_classifier = toc;
            time_N(N_idx) = time_N(N_idx) + time_classifier;
            fprintf('   Finished %s, time = %d seconds.\n',name{c},time_classifier);
        end
  
        fprintf('Time for experiment %d, N=%d is %d\n',exp,num_samples,time_N(N_idx));
    end
    
    clf
    plot_roc_multi
    hold on
    pause(1)
    
    time_exp = time_exp + sum(time_N);
    fprintf('Total time for experiment %d is %d\n',exp,time_exp);
    total_time = total_time + time_exp;
    eval(mat_file_command);
end

fprintf('Total running time for all experiments is %d seconds.\n',total_time);
diary off

% struct('classifier', @kci_classifier, 'prealloc', @kci_prealloc, 'kernel', LA, 'thresholds', thresholds, 'color', 'r' ,'params',[],'normalize',true,'name','KCI, laplace kernel'), ...
% struct('classifier', @kci_classifier, 'prealloc', @kci_prealloc, 'kernel', Ind, 'thresholds', thresholds, 'color', 'r' ,'params',[],'normalize',true,'name','KCI, indicator kernel'), ...
% struct('classifier', @kci_classifier, 'prealloc', @kci_prealloc, 'kernel', P, 'thresholds', thresholds, 'color', 'k' ,'params',[],'normalize',true,'name','KCI, heavytail kernel'), ...
% struct('classifier', @sb_classifier, 'prealloc', @dummy_prealloc, 'kernel', empty,'thresholds',thresholds, 'color', 'm','params',struct('eta',0.01,'alpha',1.0),'normalize',false,'name','bayesian conditional MI')};