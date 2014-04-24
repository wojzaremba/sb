
% Generate same automatic test from asia network.
% Add this as a test.
S = cell(3);
small = -10000;
indep = -0.1;
S{1} = {struct('score', indep,'parents', []), ...
    struct('score', dep ,'parents', [2]), ...
    struct('score', dep ,'parents', [3]), ...
    struct('score', dep ,'parents', [2 3])};
S{2} = {struct('score', indep,'parents', []), ...
    struct('score', dep ,'parents', [1]), ...
    struct('score', dep ,'parents', [3]), ...
    struct('score', dep ,'parents', [1 3])};
S{3} = {struct('score', indep,'parents', []), ...
    struct('score', dep ,'parents', [1]), ...
    struct('score', dep ,'parents', [2]), ...
    struct('score', dep ,'parents', [1 2])};

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

% write score file
score = '';
fid = fopen([gobnilp_in_file, '.score'], 'w');
nodes = size(S,1);
fprintf(fid,'%d\n',nodes);
for i = 1:size(S,1)
    count = 0; % count # of lines we will add
    for j = i+1:size(S,2)
        if ~(isempty(S{i,j}))
            count = count + length(S{i,j});
        end
    end
    if (count > 0)
        fprintf(fid,'%d %d\n', i - 1, count);
        for j = i+1:size(S,2)
            if ~(isempty(S{i,j}))
                for k = 1:length(S{i,j})
                    fprintf(fid,'%f %d ', S{i,j}{k}.score, length(S{i,j}{k}.parents);
                    for p = 1:length(S{i,j}{k}.parents)
                        fprintf(fid,'%d ',S{i,j}{k}.parents(p) - 1);
                    end
                    fprintf(fid, '\n');
                end
            end
        end
    end
end
fprintf(fid, score);
fclose(fid);

% call gobnilp
command = sprintf('gobnilp/bin/gobnilp -g%s %s', ...
    [gobnilp_in_file, '.set'], ...
    [gobnilp_in_file, '.score']);
[status, cmdout] = system(command);
