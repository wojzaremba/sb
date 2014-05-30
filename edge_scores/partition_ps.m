function set = partition_ps(out)

for s = 0:max(out.set_size)
    idx = find(out.set_size == s);
    set{s+1}.p = out.p(idx);
    set{s+1}.sta = out.sta(idx);
    set{s+1}.edge = logical(out.edge(idx));
    set{s+1}.ind = logical(out.ind(idx));
end