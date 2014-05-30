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
<<<<<<< HEAD
    ret = '/web/hodos/code/gobnilp/gobnilp1.3/bin/gobnilp';
    fprintf('warning: overriding gobnilp code pointing to executable\n');
=======
    %assert(0); % because code on crunchy needs to be fixed here.
>>>>>>> d52da956b58888e5c55810199b15c0872d44df72
end
