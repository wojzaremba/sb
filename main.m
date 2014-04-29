function main(network, final_arity, type, N, variance, num_exp, class_select)

%clear all;
global debug
debug = 0;
close all;

if exist('variance','var')
    v = variance;
else
    v = [];
end

a = strsplit('_',type);
cpd_type = a{1};

% defaults
discretize = false;
starting_arity = final_arity;

if ( strcmpi(a{2},'ggm') && final_arity > 1)
    discretize = true;
    starting_arity = 1;
end

if final_arity > 1
    dis_or_cts = 'discrete';
else
    dis_or_cts = 'cts';
end

bn_opt = struct('variance', v, 'network', network, 'arity', starting_arity, 'type', type);
bnet = make_bnet(bn_opt);
arity = final_arity;

file_name = sprintf('%s_%s_arity%d_N%d',network, cpd_type, final_arity, N);
dir_name = sprintf('results/2014_04_30/%s/%s', dis_or_cts, file_name);
system( ['mkdir -p ' dir_name]);
%system(['cp call_main.m ' dir_name '/']);
mat_file_command = sprintf('save %s/%s.mat', dir_name, file_name);
diary(sprintf('%s/%s.out', dir_name, file_name));
fprintf('Will %s\n', mat_file_command);

K = length(bnet.dag);
max_S = 2;
% if final_arity >= 20
%   fprintf('WARNING: changing max_S to 1\n');
%   max_S = 1;
% end

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
           struct('classifier', @kci_classifier,'rho_range', rho_range, 'prealloc', @kci_prealloc, 'kernel', LA, 'thresholds', thresholds, 'color', 'r' ,'params',[],'normalize',true,'name','KCI, laplace kernel'), ...
           struct('classifier', @kci_classifier,'rho_range', rho_range, 'prealloc', @kci_prealloc, 'kernel', Ind, 'thresholds', thresholds, 'color', 'r' ,'params',[],'normalize',true,'name','KCI, indicator kernel'), ...
           struct('classifier', @kci_classifier,'rho_range', rho_range, 'prealloc', @kci_prealloc, 'kernel', P, 'thresholds', thresholds, 'color', 'k' ,'params',[],'normalize',true,'name','KCI, heavytail kernel'), ...
           struct('classifier', @cc_classifier,'rho_range', rho_range, 'prealloc', @dummy_prealloc, 'kernel', empty, 'thresholds', thresholds, 'color', 'r','params',[],'normalize',false,'name','cond corr, min'), ...          
           struct('classifier', @mi_classifier,'rho_range', [0 log2(arity)], 'prealloc', @dummy_prealloc, 'kernel', empty, 'thresholds', 0:step_size:log2(arity), 'color', 'k','params',[],'normalize',false,'name','cond MI, min'), ...
           struct('classifier', @sb_classifier, 'rho_range', rho_range,'prealloc', @dummy_prealloc, 'kernel', empty,'thresholds',thresholds, 'color', 'm','params',struct('eta',0.01,'alpha',1.0),'normalize',false,'name','bayesian conditional MI')};
       
options = full_options(class_select);
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
        if (discretize)
            s = discretize_data(s,arity);
        end
        s_norm = normalize_data(s);
        
        for c = 1:num_classifiers
            tic;
            o = options{c};
            opt = struct('arity', arity, 'kernel', o.kernel,'thresholds', o.thresholds,'params',o.params,'normalize',o.normalize, 'rho_range', o.rho_range); %, 'aggregation',o.aggregation);
            
            % allocate
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
                rho = classifier_wrapper(emp, triples{t}, o.classifier, opt, prealloc);
                rho = rho(1);
                
                
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
    
%     clf
%     plot_roc_multi
%     hold on
%     pause(1)
    
    time_exp = time_exp + sum(time_N);
    fprintf('Total time for experiment %d is %d\n',exp,time_exp);
    total_time = total_time + time_exp;
    eval(mat_file_command);
end

fprintf('Total running time for all experiments is %d seconds.\n',total_time);
diary off
