function D = read_gals_data(dataname)

check_dir();

if strcmpi(dataname, 'DOW')
    base_name = 'data/DOW/dow.delta';
elseif strcmpi(dataname, 'wine')
    base_name = 'data/wine/wine-red';
else
    error('unexpected dataname');
end

for i = 1:10
    D{i}.train = load(sprintf('%s.%d.datac', base_name, i));
    D{i}.test = load(sprintf('%s.%d.testc', base_name, i));
    assert(all(all(~isnan(D{i}.train))));
    assert(all(all(~isinf(D{i}.train))));
    assert(all(all(~isnan(D{i}.test))));
    assert(all(all(~isinf(D{i}.test))));
end

