disp('test_add_edge_scores...');

data = load('asia1000.dat');
data = data';
data(data == 0) = 2;
arity = 2;

opt = struct('classifier', @sb_classifier,'prealloc', @dummy_prealloc,...
    'params',struct('eta',0.01,'alpha',1.0), 'arity', arity);

maxpa = 2;
max_cond_set = 0;
S = compute_bic(data, arity, maxpa);
[E,R] = compute_edge_scores(data, opt, max_cond_set);
S = add_edge_scores(S, E);
S = prune_scores(S);

my_file = 'gobnilp/in/test_bic_sb.score';
fid = fopen(my_file, 'w');
write_gobnilp_scores(fid,S);
fclose(fid);

baseline_file = 'asia1000_bic_sb_cpp.score';

command = sprintf('diff --side-by-side test/asia1000/%s %s', baseline_file, my_file);
assert(system(command) == 0);

% my_fid = fopen(my_file,'r');
% fid = fopen(baseline_file,'r');
% 
% my_score_vector = textscan(my_fid,'%f','delimiter',' ');
% baseline_score_vector = textscan(fid,'%f','delimiter',' ');
% 
% assert(norm(cell2mat(my_score_vector) - cell2mat(baseline_score_vector)) < 1e-2);