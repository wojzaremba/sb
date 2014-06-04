function scrub_gals_data(dataname)
% dataname should be either 'DOW' or 'wine'

check_dir();

if strcmpi(dataname, 'DOW') 
    base_name = 'data/DOW/dow.delta';
elseif strcmpi(dataname, 'wine')
    base_name = 'data/wine/wine-red';
else
    error('unexpected dataname');
end

for i = 1:10
    scrub(sprintf('%s.%d.data', base_name, i));
    scrub(sprintf('%s.%d.test', base_name, i));
end

end

function scrub(in_file)
out_file = [in_file 'c'];
fin = fopen(in_file, 'r');
fout = fopen(out_file, 'w');
tline = fgets(fin);
while ischar(tline)
    fprintf(fout, '%s\n', tline(2:end-2));
    tline = fgets(fin);    
end
fclose(fin);
fclose(fout);
end
