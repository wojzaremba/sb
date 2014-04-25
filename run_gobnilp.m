
% Generate same automatic test from asia network.
% Add this as a test.
% S = cell(3);
% small = -10000;
% indep = -0.1;
% S{1} = {struct('score', indep,'parents', []), ...
%     struct('score', dep ,'parents', [2]), ...
%     struct('score', dep ,'parents', [3]), ...
%     struct('score', dep ,'parents', [2 3])};
% S{2} = {struct('score', indep,'parents', []), ...
%     struct('score', dep ,'parents', [1]), ...
%     struct('score', dep ,'parents', [3]), ...
%     struct('score', dep ,'parents', [1 3])};
% S{3} = {struct('score', indep,'parents', []), ...
%     struct('score', dep ,'parents', [1]), ...
%     struct('score', dep ,'parents', [2]), ...
%     struct('score', dep ,'parents', [1 2])};

fid = fopen('gobnilp/gobnilp.set', 'r');

str = '';
tline = fgets(fid);
while ischar(tline)
    str = sprintf('%s%s', str, tline);
    tline = fgets(fid);    
end
fclose(fid);

gobnilp_in_file = sprintf('gobnilp/in/gobnilp-%s', strrep(strrep(datestr(clock), ' ', '_'), ':', '_'));
gobnilp_out_file = strrep(gobnilp_in_file, 'in', 'out');
fid = fopen([gobnilp_in_file, '.set'],'w');
str = strrep(str, 'ADJ', [gobnilp_out_file, '.adj']);
str = strrep(str, 'DOT', [gobnilp_out_file, '.dot']);
str = strrep(str, 'SCORE_AND_TIME', [gobnilp_out_file, '.time']);
str = strrep(str, 'STATISTICS_FILE', [gobnilp_out_file, '.stats']);
fprintf(fid, str);
fclose(fid);

% generate network and sample data
bnet = mk_bnet4_vstruct();
arity = get_arity(bnet);
emp = samples(bnet,10000);
S = compute_bic(emp, arity);

% write score file
score_file = [gobnilp_in_file, '.score'];
write_gobnilp_scores(score_file,S);

% call gobnilp
command = sprintf('gobnilp/bin/gobnilp -g%s %s', ...
    [gobnilp_in_file, '.set'], ...
    [gobnilp_in_file, '.score']);
[status, cmdout] = system(command);
