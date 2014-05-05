function ret = gobnilp()
    [~, name] = system('hostname');
    name = strtrim(lower(name));
    if (length(findstr(name, 'wojciech')) > 0)
        ret = '/Users/wojto/sb/gobnilp/bin/gobnilp';
    elseif (length(findstr(name, 'rachel')) > 0)
        ret = '/Users/rhodos/Desktop/Research/Thesis/Software/gobnilp/bin/gobnilp';
    else
        ret = '/web/hodos/code/gobnilp/gobnilp1.3/bin/gobnilp';
    end
end
