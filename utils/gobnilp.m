function ret = gobnilp()
    [~, name] = system('whoami');
    name = strtrim(lower(name));
    if (length(findstr(name, 'wojto')) > 0)
        ret = '/Users/wojto/sb/gobnilp/bin/gobnilp';
    elseif ((length(findstr(name, 'rhodos')) > 0) || (length(findstr(name, 'dynapool.nyu.edu')) > 0) )
        ret = '/Users/rhodos/Desktop/Research/Thesis/Software/gobnilp/bin/gobnilp';
    else
        ret = '/web/hodos/code/gobnilp/gobnilp1.3/bin/gobnilp';
    end
end
