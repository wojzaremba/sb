function [G, solving_time] = run_gobnilp(S)

% define file names
gobnilp_in_file = sprintf('gobnilp/in/gobnilp-%s', strrep(strrep(datestr(clock), ' ', '_'), ':', '_'));
gobnilp_out_file = strrep(gobnilp_in_file, 'in', 'out');
set_file = [gobnilp_in_file, '.set'];
adj_file = [gobnilp_out_file, '.adj'];
dot_file = ''; %[gobnilp_out_file, '.dot'];
time_file = ''; %[gobnilp_out_file, '.time'];
stats_file = ''; %[gobnilp_out_file, '.stats'];
score_file = [gobnilp_in_file, '.score'];
out_file = [gobnilp_out_file, '.out'];

% read settings file
fid = fopen('gobnilp/gobnilp.set', 'r');
str = '';
tline = fgets(fid);
while ischar(tline)
    str = sprintf('%s%s', str, tline);
    tline = fgets(fid);    
end
fclose(fid);

% modify settings file to point to appropriate output names
fid = fopen(set_file,'w');
str = strrep(str, 'ADJ', adj_file);
str = strrep(str, 'DOT', dot_file);
str = strrep(str, 'SCORE_AND_TIME', time_file); 
str = strrep(str, 'STATISTICS_FILE', stats_file); 
fprintf(fid, str);
fclose(fid);

% write score file
fid = fopen(score_file, 'w');
write_gobnilp_scores(fid,S);
fclose(fid);

% call gobnilp
command = sprintf('%s -g%s %s > %s', gobnilp(), set_file, score_file, out_file);
[status, cmdout] = system(command);

% ~~~ get information from gobnilp
% solution
G = load(adj_file);

% runtime
[status, solving_str] = system(sprintf('grep "Solving Time (sec)" %s', out_file));
solving_str_split = regexp(solving_str, ' : ', 'split');
solving_time = str2num(solving_str_split{2});

% check that it converged
[status, cvg_str] = system(sprintf('grep "SCIP Status" %s', out_file));
cvg_str_split = regexp(cvg_str, ' : ', 'split');
assert(strcmp(strtrim(cvg_str_split{3}),'problem is solved [optimal solution found]'));

% delete output files
command = sprintf('rm %s %s %s %s', adj_file, score_file, out_file, set_file);
system(command);
