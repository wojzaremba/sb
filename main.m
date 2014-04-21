
% XXXX  TODO ????
% 1. Create tests for conditioned classifiers.
% 2. What is the difference between conditional correlation and partial
% correlation in the binary case?
% 3. Why do GaussKernel, LinearKernel and IndicatorKernel give the same numbers for binary
% data? (without conditioning)?  They are just computing partial
% correlation.  This does not hold for ternary data.  Should also check if
% its true if I condition.
% 4. writes tests for mk_bnet functions
% 5. Cache kernel matrices / inspect which part is slow. 
% 6. Check if glueing would recover results of mutual information
% 9. Explore manually which kernels work well. It's enough to have a paper
% on a good kernel.
% 10. If a BN tells me about the correlation structure in the data, is there a way to use this to directly compute a data transformation in which the data are no longer correlated?  Is this what I want for a drug-repurposing metric? 

% clear all;
global debug
debug = 0;
close all;

cpd_type = 'linear'; %%%
discrete = false; %%%
bnet = mk_child_linear_gauss(0.5); %%%
arity = get_arity(bnet);
if (~discrete)
    disp('not discrete, setting arity separately');
    arity = 2; %%%
end
K = length(bnet.dag);
max_S = 2;

num_experiments = 3;%20;
num_samples_range = [50];% 200 500];
num_N = length(num_samples_range);
step_size = 1e-3;
range = 0:step_size:1;
%eta_range = log2(1:0.01:1.2);%log2(1:.001:1.1);
%alpha_range = [0 10.^(-3:0.2:3)];%[0 10.^(-3:0.2:3)];

empty = struct('name', 'none');
L = LinearKernel();
G = GaussKernel();
% C1 = CombKernel({L, G}, {-0.1, 1});
LA = LaplaceKernel();
P = PKernel();
Ind = IndKernel();
full_options = {struct('classifier', @kci_classifier, 'prealloc', @kci_prealloc, 'kernel', L,'range', range, 'color', 'g' ,'params',[],'normalize',true,'name','KCI, linear kernel'), ...
           struct('classifier', @kci_classifier, 'prealloc', @kci_prealloc, 'kernel', G, 'range', range, 'color', 'b','params',[],'normalize',true,'name','KCI, gaussian kernel'), ...
           struct('classifier', @kci_classifier, 'prealloc', @kci_prealloc, 'kernel', LA, 'range', range, 'color', 'm' ,'params',[],'normalize',true,'name','KCI, laplace kernel'), ...
           struct('classifier', @kci_classifier, 'prealloc', @kci_prealloc, 'kernel', Ind, 'range', range, 'color', 'r' ,'params',[],'normalize',true,'name','KCI, indicator kernel'), ...
           struct('classifier', @kci_classifier, 'prealloc', @kci_prealloc, 'kernel', P, 'range', range, 'color', 'k' ,'params',[],'normalize',true,'name','KCI, heavytail kernel'), ...
           struct('classifier', @cc_classifier, 'prealloc', empty, 'kernel', empty, 'range', range, 'color', 'c','params',[],'normalize',false,'name','conditional correlation'), ...
           struct('classifier', @mi_classifier, 'prealloc', empty, 'kernel', empty, 'range', 0:step_size:log2(arity), 'color', 'y','params',[],'normalize',false,'name','conditional MI'), ...
           struct('classifier', @sb_classifier, 'prealloc', empty, 'kernel', empty,'range',range, 'color', 'm','params',struct('eta',0.01,'alpha',1.0),'normalize',false,'name','bayesian conditional MI')};
       
                  %struct('classifier', @pc_classifier, 'kernel', empty,
                  %'range', range, 'color',
                  %'r','params',[],'normalize',true,'name','partial
                  %correlation'), ...

options = full_options([1 2 4 6 7 8]);
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
    num_thresholds = length(o.range);
    
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
        if (~discrete)
            s = discretize(s,arity);
        end
        s_norm = normalize_data(s);
        
        for c = 1:num_classifiers
            tic;
            o = options{c};
            opt = struct('arity', arity, 'kernel', o.kernel,'range', o.range,'params',o.params,'normalize',o.normalize);
            
            % allocate
            classes = zeros([length(o.range) param_size{c}]);
            num_thresholds = length(o.range);
            scores = zeros([2 2 num_thresholds param_size{c}]);
            
            if o.normalize
                emp = s_norm;
            else
                emp = s;
            end            
            
            % apply classifier
            prealloc = o.prealloc(emp, opt);
            for t = 1 : length(triples)
                
                % evaluate classifier at all thresholds in range
                indep_emp = classifier_wrapper(emp, triples{t}, o.classifier, prealloc, opt); %o.classifier(emp, opt);
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


fprintf('Total running time for all experiments is %d seconds.\n',total_time);
mat_file_command = sprintf('save child_%s_arity%d_N%d.mat',cpd_type,arity,num_samples);
eval(mat_file_command);
