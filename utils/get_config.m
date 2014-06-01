function ret = get_config(varname)

check_dir();
fid = fopen('config/config.txt','r');

tline = fgets(fid);
while ischar(tline)
    if strfind(tline, upper(varname))
        break;
    end
    tline = fgets(fid);
end
fclose(fid);

if ischar(tline)
    C = strsplit(tline, '=');
    ret = strtrim(C{2});
else
    error('Could not get %s', varname);
end

end