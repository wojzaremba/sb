function G = run_gobnilp(data, arity)

maxpa = 2;
S = compute_bic(data, arity, maxpa);

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
set_file = [gobnilp_in_file, '.set'];
adj_file = [gobnilp_out_file, '.adj'];
fid = fopen(set_file,'w');
str = strrep(str, 'ADJ', adj_file);
str = strrep(str, 'DOT', [gobnilp_out_file, '.dot']);
str = strrep(str, 'SCORE_AND_TIME', [gobnilp_out_file, '.time']);
str = strrep(str, 'STATISTICS_FILE', [gobnilp_out_file, '.stats']);
fprintf(fid, str);
fclose(fid);

%% generate network and sample data
%bnet = mk_bnet4_vstruct();
%arity = get_arity(bnet);
%emp = samples(bnet,10000);
%S = compute_bic(emp, arity);

% write score file
score_file = [gobnilp_in_file, '.score'];
fid = fopen(score_file, 'w');
write_gobnilp_scores(fid,S);
fclose(fid);

% call gobnilp
command = sprintf('%s -g%s %s', ...
	getenv('GOB'), ...
    [gobnilp_in_file, '.set'], ...
    score_file);
[status, cmdout] = system(command);

G = load(adj_file);
