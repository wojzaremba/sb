function run_rocs(cpd_type,N,arity)

clear all;
global debug
debug = 0;
close all;

discretize = false;
discrete = true;
if strcmpi(cpd_type,'linear')
  bnet = mk_child_linear_gauss(0.5);
    if (arity >= 2)
      discretize = true;
    else
      discrete = false;
    end
elseif strcmpi(cpd_type,'random')
  if (arity >=2)
    bnet = mk_child_random(arity)
  else
    error('cant have arity < 2 with discrete (random) cpds');
  end
else
  error('unexpected cpd_type');
end

K = length(bnet.dag);
max_S = 2;
num_experiments = 20;
num_samples_range = N;
num_N = length(num_samples_range);
step_size = 1e-3;
thresholds = 0:step_size:1;
rho_range = [0 1];

empty = struct('name', 'none');
L = LinearKernel();
G = GaussKernel();
LA = LaplaceKernel();
P = PKernel();
Ind = IndKernel();
full_options = {struct('classifier', @kci_classifier, 'rho_range', rho_range, 'prealloc', @kci_prealloc, 'kernel', L,'thresholds', thresholds, 'color', 'g' ,'params',[],'normalize',true,'name','KCI, linear kernel'), ...
           struct('classifier', @kci_classifier,'rho_range', rho_range, 'prealloc', @kci_prealloc, 'kernel', G, 'thresholds', thresholds, 'color', 'b','params',[],'normalize',true,'name','KCI, gaussian kernel'), ...
           struct('classifier', @kci_classifier,'rho_range', rho_range, 'prealloc', @kci_prealloc, 'kernel', LA, 'thresholds', thresholds, 'color', 'k' ,'params',[],'normalize',true,'name','KCI, laplace kernel'), ...
           struct('classifier', @kci_classifier,'rho_range', rho_range, 'prealloc', @kci_prealloc, 'kernel', Ind, 'thresholds', thresholds, 'color', 'r' ,'params',[],'normalize',true,'name','KCI, indicator kernel'), ...
           struct('classifier', @kci_classifier,'rho_range', rho_range, 'prealloc', @kci_prealloc, 'kernel', P, 'thresholds', thresholds, 'color', 'k' ,'params',[],'normalize',true,'name','KCI, heavytail kernel'), ...
           struct('classifier', @cc_classifier,'rho_range', rho_range, 'prealloc', @dummy_prealloc, 'kernel', empty, 'thresholds', thresholds, 'color', 'c','params',[],'normalize',false,'name','conditional correlation'), ...
           struct('classifier', @mi_classifier,'rho_range', [0 log2(arity)], 'prealloc', @dummy_prealloc, 'kernel', empty, 'thresholds', 0:step_size:log2(arity), 'color', 'y','params',[],'normalize',false,'name','conditional MI'), ...
           struct('classifier', @sb_classifier, 'rho_range', rho_range,'prealloc', @dummy_prealloc, 'kernel', empty,'thresholds',thresholds, 'color', 'm','params',struct('eta',0.01,'alpha',1.0),'normalize',false,'name','bayesian conditional MI')};
       

a = [1 2 3 4 6 7];
if (~(discrete) && ~isempty(intersect(a,[7 8])))
  error('cant run sb or mi classifier without discrete data');
end
options = full_options(a);
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
    num_thresholds = length(o.thresholds);
    
    param_size{c} = [];
    if (isstruct(o.params))
        fields = fieldnames(o.params);
        for i = 1:length(fields)
            param_size{c} = [param_size{c} length(o.params.(fields{i}))];
        end
    end
    
end

total_time = 0;

for exp = 1:num_experiments
    time_N = zeros(num_N,1);
    time_exp = 0;

    for N_idx = 1:num_N
        
        num_samples = num_samples_range(N_idx);
        fprintf('STARTING N=%d.\n',num_samples);
        
        fprintf('Experiment #%d, N=%d, sampling from bayes net...\n',exp,num_samples);
        s = samples(bnet, num_samples);
        fprintf('... done.\n');
        if (discretize)
            s = discretize(s,arity);
        end
        s_norm = normalize_data(s);
        
        for c = 1:num_classifiers
            tic;
            o = options{c};
            opt = struct('arity', arity, 'kernel', o.kernel,'thresholds', o.thresholds,'params',o.params,'normalize',o.normalize, 'rho_range', o.rho_range);
            
            % allocate
            classes = zeros([length(o.thresholds) param_size{c}]);
            num_thresholds = length(o.thresholds);
            scores = zeros([2 2 num_thresholds param_size{c}]);
            
            if o.normalize
                emp = s_norm;
            else
                emp = s;
            end            
            
            % apply classifier
            prealloc = o.prealloc(emp, opt);
            for t = 1 : length(triples)
                
                % evaluate classifier at all thresholds in thresholds
                indep_emp = classifier_wrapper(emp, triples{t}, o.classifier, opt, prealloc); %o.classifier(emp, opt);
                indep_emp = reshape(indep_emp,[1 1 size(indep_emp)]);
                
                % increment scores accordingly (WARNING: HARD-CODED max num
                % params to optimize as 2)
                scores(1 + no_edge(t),1,:,:,:) = scores(1 + no_edge(t),1,:,:,:) + ~indep_emp;
                scores(1 + no_edge(t),2,:,:,:) = scores(1 + no_edge(t),2,:,:,:) + indep_emp;
            end

            P = scores(2, 1, :, :, :) + scores(2, 2, :, :, :);
            N = scores(1, 1, :, :, :) + scores(1, 2, :, :, :);
            TP = scores(2, 2, :, :, :);
            TN = scores(1, 1, :, :, :);
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
end

if (discrete)
  dis_or_cts = 'discrete';
else
  dis_or_cts = 'cts';
end
fprintf('Total running time for all experiments is %d seconds.\n',total_time);
mat_file_command = sprintf('save results/2014_04_22/%s/%s_arity%d_N%d.mat',cpd_type,arity,num_samples);
eval(mat_file_command);
