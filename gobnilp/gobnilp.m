function ret = gobnilp()
    [~, name] = system('hostname');
    name = strtrim(lower(name));
    if (length(findstr(name, 'wojciech')) > 0)
        ret = '/Users/wojto/sb/gobnilp/bin/gobnilp';
    elseif (length(findstr(name, 'rachel')) > 0)
        ret = '~/Desktop/Research/Thesis/sb/gobnilp/bin/gobnilp';
    else
        assert(0);
    end
end