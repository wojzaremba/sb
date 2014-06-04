function ret = is_discrete(data, arity)

ret = all(ismember(unique(data), 1:arity));
