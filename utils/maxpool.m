function ret = maxpool()
    ret = str2num(getenv('MAXPOOL'));
    if isempty(ret)
        error(['did not get MAXPOOL from environment.  '...
            'Should set variable $MAXPOOL.']);
    end
end