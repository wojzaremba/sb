disp('test_compute_bic...');

% this really tests compute_bic, compute_bic_family, prune_scores, and
% write_gobnilp_scores

data = load('asia1000.dat');
data = data';
data(data == 0) = 2;
arity = 2;

S = compute_bic(data, arity, 2);
S = prune_scores(S);

my_file = 'thirdparty/gobnilp/in/test_bic.score';
fid = fopen(my_file, 'w');
write_gobnilp_scores(fid,S);
fclose(fid);

baseline_file = 'asia1000_bic_cpp.score';

%command = sprintf('diff --side-by-side test/%s %s', baseline_file, my_file);
%assert(system(command) == 0);
my_fid = fopen(my_file,'r');
fid = fopen(baseline_file,'r');

my_score_vector = textscan(my_fid,'%f','delimiter',' ');
baseline_score_vector = textscan(fid,'%f','delimiter',' ');

assert(norm(cell2mat(my_score_vector) - cell2mat(baseline_score_vector)) < 1e-2);


