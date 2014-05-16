function check_dir()   

% check that we are in the sb directory
fulldir = strsplit('/',pwd);
assert(strcmpi(fulldir{end},'sb'));