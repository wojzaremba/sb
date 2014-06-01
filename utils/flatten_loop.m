function pair = flatten_loop(M,N)

pair = {};

for i = 1:M
    for j = 1:N
        next.i = i;
        next.j = j;
        pair{end+1} = next;
    end
end

end